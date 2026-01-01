defmodule PolytanWeb.AccountController do
  use PolytanWeb, :controller
  alias Polytan.Repo
  alias Ecto.Multi

  alias PolytanWeb.Auth.Guardian
  alias Polytan.Context.Account.{Accounts, Users, AccountMemberships}
  alias Polytan.Schema.Accounts.{Account, User}
  alias Polytan.Core.{Permissions, RequestValidator, Password}
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  plug :authorize_action when action in [:transfer_ownership]
  plug :validate_fields when action in ~w[login transfer_ownership]a

  @account_owner "account.owner"
  @account_admin "account.admin"
  @login_fields ~w[email password]
  @transfer_fields ~w[new_owner_id]

  def register(conn, params) do
    case Accounts.create_account_with_owner(params) do
      {:ok, %{user: user, account: _account}} ->
        with {:ok, token} <- Guardian.create_token(user, :access),
             %User{account_memberships: memberships} = user <- Users.load_accounts(user.id),
             [_ | _] <- memberships do
          conn
          |> put_status(:created)
          |> render(:show, user: user, token: token)
        else
          [] -> {:error, :no_active_accounts}
          {:error, reason} -> {:error, reason}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    with %User{} = user <- Users.get_by_email(email),
         true <- Password.validate(password, user.password),
         {:ok, token} <- Guardian.create_token(user, :access),
         %User{account_memberships: memberships} = user <- Users.load_accounts(user.id),
         [_ | _] <- memberships do
      conn
      |> put_status(:ok)
      |> render(:show, user: user, token: token)
    else
      [] -> {:error, :no_active_accounts}
      _ -> {:error, :invalid_credentials}
    end
  end

  def transfer_ownership(conn, %{"new_owner_id" => new_owner_id} = _params) do
    current_account = conn.assigns.current_account
    update_params = %{owner_id: new_owner_id}

    with {:ok, old_owner} <-
           validate_membership(current_account, current_account.owner_id, "Current owner"),
         {:ok, _} <- validate_membership(current_account, new_owner_id, "New owner"),
         true <- ensure_not_an_owner(current_account, new_owner_id),
         {:ok, _changes} <-
           transfer_account_ownership(current_account, update_params, old_owner, new_owner_id) do
      Response.respond(conn, :ok, "Account ownership transferred")
    else
      {:error, message} when is_binary(message) ->
        Response.send_error(conn, :bad_request, message)

      false ->
        Response.send_error(conn, :bad_request, "New owner is already the account owner")

      {:error, _step, reason, _changes} ->
        Response.send_error(conn, :unprocessable_entity, reason)
    end
  end

  @dialyzer {:nowarn_function, transfer_account_ownership: 4}
  defp transfer_account_ownership(account, update_params, old_owner, new_owner_id) do
    Multi.new()
    |> Multi.update(:account, Accounts.change(account, update_params))
    |> update_permissions(account.id, old_owner, new_owner_id)
    |> Repo.transaction()
  end

  defp validate_membership(account, user_id, role_description) do
    case AccountMemberships.get_active_membership(account.id, user_id) do
      nil -> {:error, "#{role_description} not a member of this account"}
      membership -> {:ok, membership}
    end
  end

  defp ensure_not_an_owner(account, new_owner_id) do
    case AccountMemberships.get_active_membership(account.id, new_owner_id) do
      nil -> true
      membership -> @account_owner not in membership.permissions
    end
  end

  defp update_permissions(multi, account_id, old_owner, new_owner_id) do
    Multi.run(multi, :permissions, fn _repo, _changes ->
      case AccountMemberships.get_active_membership(account_id, new_owner_id) do
        nil ->
          {:error, "New owner not a member of this account"}

        new_owner ->
          new_owner_perms = update_owner_role(new_owner.permissions, :grant)
          old_owner_perms = update_owner_role(old_owner.permissions, :revoke)

          with {:ok, _} <-
                 AccountMemberships.update(old_owner, %{permissions: old_owner_perms}),
               {:ok, _} <-
                 AccountMemberships.update(new_owner, %{permissions: new_owner_perms}) do
            {:ok, :permissions_updated}
          else
            {:error, reason} -> {:error, reason}
          end
      end
    end)
  end

  defp update_owner_role(permissions, :revoke) do
    permissions
    |> MapSet.new()
    |> MapSet.delete(@account_owner)
    |> MapSet.to_list()
  end

  defp update_owner_role(permissions, :grant) do
    permissions
    |> MapSet.new()
    |> MapSet.put(@account_owner)
    |> MapSet.to_list()
  end

  defp authorize_action(conn, _opts) do
    permission = assert_fields(conn, :authorize)

    case Permissions.authorize(conn, permission) do
      :ok -> conn
      {:error, reason} -> Response.permission_response(conn, reason)
    end
  end

  defp validate_fields(conn, _opts) do
    fields = assert_fields(conn, :validate)

    case RequestValidator.validate_required(conn.params, fields) do
      {:ok, _} -> conn
      {:error, errors} -> Response.send_errors(conn, errors)
    end
  end

  defp assert_fields(conn, :authorize) do
    case conn.private.phoenix_action do
      :transfer_ownership -> @account_admin
    end
  end

  defp assert_fields(conn, :validate) do
    case conn.private.phoenix_action do
      :login -> @login_fields
      :transfer_ownership -> @transfer_fields
    end
  end
end

defmodule PolytanWeb.AccountController do
  use PolytanWeb, :controller
  alias Polytan.Repo

  alias Polytan.Context.Account.{Accounts, Users, AccountMemberships}
  alias Polytan.Schema.Accounts.{Account, User}
  alias PolytanWeb.Auth.Guardian
  alias Polytan.Core.Password
  alias Polytan.Utils.Response
  alias Polytan.Core.Permissions

  require Logger

  action_fallback PolytanWeb.FallbackController

  plug :authorize_action when action in [:transfer_ownership]

  @account_owner "account.owner"
  @account_admin "account.admin"

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
          [] ->
            {:error, :no_active_accounts}

          {:error, reason} ->
            {:error, reason}
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
      [] ->
        {:error, :no_active_accounts}

      _ ->
        {:error, :invalid_credentials}
    end
  end

  def login(_conn, _params) do
    {:error, :bad_request}
  end

  def me(conn, _params) do
    case {conn.assigns.current_account, conn.assigns.current_user} do
      {nil, _} ->
        {:error, :unauthenticated}

      {current_account, current_user} ->
        user = Users.load_accounts(current_user.id)

        render(conn, :show, %{
          user: user,
          current_account: current_account
        })
    end
  end

  def transfer_ownership(conn, %{"new_owner_id" => new_owner_id} = _params) do
    current_account = conn.assigns.current_account

    with {:ok, old_owner} <-
           validate_membership(current_account, current_account.owner_id, "Current owner"),
         {:ok, _new_owner} <- validate_membership(current_account, new_owner_id, "New owner"),
         true <- ensure_not_an_owner(current_account, new_owner_id),
         {:ok, %Account{}} <- Accounts.update_account(current_account, %{owner_id: new_owner_id}),
         :ok <- update_permissions(current_account.id, old_owner, new_owner_id) do
      Response.respond(conn, :ok, "Account ownership transferred")
    else
      {:error, message} when is_binary(message) ->
        Response.send_error(conn, :bad_request, message)

      false ->
        Response.send_error(conn, :bad_request, "New owner is already the account owner")

      {:error, reason} ->
        {:error, reason}
    end
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

  defp update_permissions(account_id, old_owner, new_owner_id) do
    case Repo.transaction(fn ->
           new_owner = AccountMemberships.get_active_membership(account_id, new_owner_id)
           old_owner_perms = update_owner_role(old_owner.permissions, :revoke)
           new_owner_perms = update_owner_role(new_owner.permissions, :grant)

           with {:ok, _} <-
                  old_owner
                  |> AccountMemberships.update_account_membership(%{permissions: old_owner_perms}),
                {:ok, _} <-
                  new_owner
                  |> AccountMemberships.update_account_membership(%{permissions: new_owner_perms}) do
             :ok
           end
         end) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
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
    permission =
      case conn.private.phoenix_action do
        :transfer_ownership -> @account_admin
      end

    case Permissions.authorize(conn, permission) do
      :ok -> conn
      {:error, reason} -> Response.permission_response(conn, reason)
    end
  end
end

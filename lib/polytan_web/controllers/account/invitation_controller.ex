defmodule PolytanWeb.InvitationController do
  use PolytanWeb, :controller
  alias Polytan.Repo
  alias Ecto.Multi

  alias Polytan.Core.Permissions
  alias Polytan.Context.Account.{Invitations, AccountMemberships, Users}
  alias Polytan.Schema.Accounts.User
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  plug :authorize_invite when action in [:create, :delete]

  def list(conn, _params) do
    invitations = Invitations.list_invitations()
    render(conn, :index, invitations: invitations)
  end

  def create(conn, %{"email" => email, "permissions" => permissions} = params) do
    %{
      current_account: current_account,
      current_user: current_user
    } = conn.assigns

    with true <- "account.owner" not in permissions,
         false <- already_member?(current_account.id, email),
         {:ok, _} <-
           params
           |> Map.put("invited_by", current_user.id)
           |> Map.put("account_id", current_account.id)
           |> Map.put("permissions", permissions)
           |> Invitations.new() do
      Response.respond(conn, :created, "Invitation sent successfully")
    else
      false ->
        Response.send_error(
          conn,
          :forbidden,
          "You can't add ownership permission. Ownership must be transferred."
        )

      {:error, :already_member} ->
        maybe_renew_membership(conn, current_account.id, params)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def accept(conn, %{"id" => id} = params) do
    with {:ok, invitation} <- Invitations.get_valid_invitation(id),
         {:ok, _changes} <- accept_invitation_transaction(params, invitation) do
      Response.respond(conn, :ok, "Invitation accepted successfully")
    else
      {:error, :invalid_invitation} ->
        {:error, "Invalid or expired invitation"}

      {:error, :membership, :already_member, _changes} ->
        {:error, "User is already a member of this account"}

      {:error, _step, %Ecto.Changeset{} = changeset, _changes} ->
        respond(conn, :unprocessable_entity, changeset)

      {:error, _step, reason, _changes} ->
        {:error, reason}
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, invitation} <- Invitations.get_invitation(id),
         {:ok, _} <- invitation |> Invitations.remove() do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, "Invitation not found"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp already_member?(account_id, email) do
    case Users.get_by_email(email) do
      nil -> false
      user -> verify_membership(account_id, user.id)
    end
  end

  @dialyzer {:nowarn_function, accept_invitation_transaction: 2}
  def accept_invitation_transaction(params, invitation) do
    Multi.new()
    |> maybe_create_user(params, invitation.email)
    |> maybe_create_membership(invitation)
    |> clear_invitation(invitation)
    |> Repo.transaction()
  end

  defp maybe_create_user(multi, params, email) do
    Multi.run(multi, :user, fn _repo, _changes ->
      case Users.get_by_email(email) do
        nil -> create_user(params, email)
        user -> {:ok, user}
      end
    end)
  end

  defp maybe_create_membership(multi, invitation) do
    Multi.run(multi, :membership, fn _repo, %{user: user} ->
      verify_membership(invitation.account_id, user, invitation)
    end)
  end

  defp clear_invitation(multi, invitation) do
    Multi.run(multi, :clear_invitation, fn _repo, _changes ->
      Invitations.remove(invitation)
    end)
  end

  defp verify_membership(account_id, user_id) do
    case AccountMemberships.get_matching_memberships(account_id, user_id) do
      [] -> false
      [_ | _] -> {:error, :already_member}
    end
  end

  defp maybe_renew_membership(conn, account_id, params) do
    with {:ok, user} <- Users.get_by_email(params["email"]),
         {:ok, membership} <- AccountMemberships.get_inactive_membership(account_id, user.id),
         {:ok, _} <-
           membership
           |> AccountMemberships.update(%{
             status: "active",
             permissions: params["permissions"]
           }) do
      Response.respond(conn, :ok, "User now an account member")
    else
      nil ->
        {:error, "User not found"}

      {:error, :not_found} ->
        {:error, "User is already a member of the account"}
    end
  end

  defp verify_membership(account_id, user, invitation) do
    case verify_membership(account_id, user.id) do
      false -> create_membership(account_id, user, invitation)
      error -> error
    end
  end

  defp create_user(params, email) do
    user_params =
      params
      |> Map.take(~w[first_name last_name password])
      |> Map.put("email", email)

    with {:ok, %User{} = user} <- Users.new(user_params) do
      {:ok, user}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_membership(account_id, user, invitation) do
    membership_params = %{
      account_id: account_id,
      user_id: user.id,
      permissions: invitation.permissions,
      invited_at: invitation.inserted_at,
      joined_at: DateTime.utc_now() |> DateTime.truncate(:second),
      invited_by: invitation.invited_by
    }

    case AccountMemberships.new(membership_params) do
      {:ok, membership} ->
        {:ok, membership}

      {:error, %Ecto.Changeset{} = changeset} ->
        if Keyword.has_key?(changeset.errors, :account_id) do
          {:error, :already_member}
        else
          {:error, changeset}
        end
    end
  end

  defp authorize_invite(conn, _opts) do
    permission =
      case conn.private.phoenix_action do
        :create -> "invite.create"
        :delete -> "invite.delete"
      end

    case Permissions.authorize(conn, permission) do
      :ok ->
        conn

      {:error, reason} ->
        Response.permission_response(conn, reason)
    end
  end

  defp respond(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{error: message})
  end
end

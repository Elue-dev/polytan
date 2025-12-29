defmodule PolytanWeb.InvitationController do
  use PolytanWeb, :controller

  alias Polytan.Core.Permissions
  alias Polytan.Context.Account.{Invitations, AccountMemberships, Users}
  alias Polytan.Schema.Accounts.{Invitation, User}
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  plug :authorize_invite when action in [:create, :delete]

  def list(conn, _params) do
    invitations = Invitations.list_invitations()
    render(conn, :index, invitations: invitations)
  end

  def create(conn, params) do
    %{
      current_account: current_account,
      current_user: current_user
    } = conn.assigns

    params =
      params
      |> Map.put("invited_by", current_user.id)
      |> Map.put("account_id", current_account.id)

    with false <- already_member?(current_account.id, params["email"]),
         {:ok, %Invitation{} = _invitation} <- Invitations.create_invitation(params) do
      conn
      |> put_status(:created)
      |> json(%{message: "Invitation sent successfully"})
    else
      {:error, :already_member} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "User is already a member of the account"})
    end
  end

  def accept(conn, %{"id" => id} = params) do
    with {:ok, invitation} <- Invitations.get_valid_invitation(id),
         {:ok, user} <- maybe_create_user(params, invitation.email),
         {:ok, _membership} <- maybe_create_membership(user, invitation),
         {:ok, _invitation} <- mark_invitation_as_accepted(invitation) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Invitation accepted successfully"})
    else
      {:error, :invalid_invitation} ->
        {:error, :invalid_invitation}

      {:error, :already_member} ->
        respond(conn, :bad_request, "Already a member")

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete(conn, %{"id" => id}) do
    case Invitations.get_invitation(id) do
      nil ->
        {:error, :invalid_invitation}

      invitation ->
        with {:ok, %Invitation{}} <- Invitations.delete_invitation(invitation) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  defp already_member?(account_id, email) do
    case Users.get_by_email(email) do
      nil -> false
      user -> verify_membership(account_id, user.id)
    end
  end

  defp maybe_create_user(params, email) do
    case Users.get_by_email(email) do
      nil -> create_user(params, email)
      user -> {:ok, user}
    end
  end

  defp maybe_create_membership(user, invitation) do
    account_id = invitation.account_id
    verify_membership(account_id, user, invitation)
  end

  defp verify_membership(account_id, user_id) do
    case AccountMemberships.get_matching_memberships(account_id, user_id) do
      [] -> false
      [_ | _] -> {:error, :already_member}
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

    with {:ok, %User{} = user} <- Users.create_user(user_params) do
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

    case AccountMemberships.create_account_membership(membership_params) do
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

  defp mark_invitation_as_accepted(invitation) do
    # TODO: should this just be deleted? or kept for audit trail?

    invitation
    |> Invitations.update_invitation(%{
      accepted_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
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

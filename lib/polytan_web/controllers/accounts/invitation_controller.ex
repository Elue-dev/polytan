defmodule PolytanWeb.InvitationController do
  use PolytanWeb, :controller

  alias Polytan.Core.Permissions
  alias Polytan.Context.Account.{Invitations, AccountMemberships, Users}
  alias Polytan.Schema.Accounts.{Invitation, AccountMembership, User}

  action_fallback PolytanWeb.FallbackController

  plug :authorize_invite when action in [:create, :delete]

  def index(conn, _params) do
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

    # Ensure not already a member
    with {:ok, %Invitation{} = _invitation} <- Invitations.create_invitation(params) do
      conn
      |> put_status(:created)
      |> json(%{message: "Invitation sent successfully"})
    end
  end

  def accept(conn, %{"token" => token} = params) do
    with {:ok, invitation} <- Invitations.get_valid_invitation(token),
         {:ok, user} <- maybe_create_user(params, invitation.email),
         {:ok, _membership} <- maybe_create_membership(conn, user, invitation),
         {:ok, _invitation} <- mark_invitation_as_accepted(invitation) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Invitation accepted successfully"})
    else
      {:error, :invalid_invitation} ->
        respond(conn, :bad_request, "Invalid or expired invitation")

      {:error, :already_member} ->
        respond(conn, :bad_request, "Already a member")

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def show(conn, %{"id" => id}) do
    invitation = Invitations.get_invitation(id)
    render(conn, :show, invitation: invitation)
  end

  def delete(conn, %{"id" => id}) do
    invitation = Invitations.get_invitation(id)

    with {:ok, %Invitation{}} <- Invitations.delete_invitation(invitation) do
      send_resp(conn, :no_content, "")
    end
  end

  defp maybe_create_user(params, email) do
    case Users.get_by_email(email) do
      nil -> create_user(params, email)
      user -> {:ok, user}
    end
  end

  defp maybe_create_membership(conn, user, invitation) do
    %{current_account: current_account} = conn.assigns

    case AccountMemberships.get_matching_memberships(current_account.id, user.id) do
      [] -> create_membership(current_account, user, invitation)
      [_ | _] -> {:error, :already_member}
    end
  end

  defp create_membership(current_account, user, invitation) do
    membership_params = %{
      account_id: current_account.id,
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

  defp mark_invitation_as_accepted(invitation) do
    # TODO: should this just be deleted?

    invitation
    |> Invitations.update_invitation(%{
      accepted_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
  end

  defp authorize_invite(conn, _opts) do
    case Permissions.authorize(conn, "invite.create") do
      :ok ->
        conn

      {:error, reason} ->
        conn
        |> put_status(status_for(reason))
        |> json(%{error: Atom.to_string(reason)})
        |> halt()
    end
  end

  defp status_for(:forbidden), do: :forbidden
  defp status_for(:unauthorized), do: :unauthorized

  defp respond(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{error: message})
  end
end

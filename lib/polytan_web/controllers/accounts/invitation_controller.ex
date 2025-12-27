defmodule PolytanWeb.InvitationController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.Invitations
  alias Polytan.Schema.Accounts.Invitation

  action_fallback PolytanWeb.FallbackController

  def index(conn, _params) do
    invitations = Invitations.list_invitations()
    render(conn, :index, invitations: invitations)
  end

  def create(conn, %{"invitation" => invitation_params}) do
    with {:ok, %Invitation{} = invitation} <- Invitations.create_invitation(invitation_params) do
      conn
      |> put_status(:created)
      |> render(:show, invitation: invitation)
    end
  end

  def show(conn, %{"id" => id}) do
    invitation = Invitations.get_invitation(id)
    render(conn, :show, invitation: invitation)
  end

  def update(conn, %{"id" => id, "invitation" => invitation_params}) do
    invitation = Invitations.get_invitation(id)

    with {:ok, %Invitation{} = invitation} <-
           Invitations.update_invitation(invitation, invitation_params) do
      render(conn, :show, invitation: invitation)
    end
  end

  def delete(conn, %{"id" => id}) do
    invitation = Invitations.get_invitation(id)

    with {:ok, %Invitation{}} <- Invitations.delete_invitation(invitation) do
      send_resp(conn, :no_content, "")
    end
  end
end

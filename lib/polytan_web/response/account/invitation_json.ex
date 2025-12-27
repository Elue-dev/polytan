defmodule PolytanWeb.Response.InvitationJSON do
  alias Polytan.Schema.Accounts.Invitation

  def index(%{invitations: invitations}) do
    %{data: for(invitation <- invitations, do: data(invitation))}
  end

  def show(%{invitation: invitation}) do
    %{data: data(invitation)}
  end

  defp data(%Invitation{} = invitation) do
    %{
      id: invitation.id,
      account_id: invitation.account_id,
      email: invitation.email,
      permissions: invitation.permissions,
      token: invitation.token,
      expires_at: invitation.expires_at,
      invited_by: invitation.invited_by,
      accepted_at: invitation.accepted_at
    }
  end
end

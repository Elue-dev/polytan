defmodule Polytan.Context.Account.Invitations do
  import Ecto.Query, warn: false
  alias Polytan.Repo

  alias Polytan.Schema.Accounts.Invitation

  def list_invitations do
    Repo.all(Invitation)
  end

  def get_invitation(id), do: Repo.get(Invitation, id)

  def get_valid_invitation(token) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    from(i in Invitation,
      where: i.token == ^token,
      where: i.expires_at > ^now,
      where: is_nil(i.accepted_at)
    )
    |> Repo.one()
    |> case do
      nil -> {:error, :invalid_invitation}
      invitation -> {:ok, invitation}
    end
  end

  def create_invitation(attrs) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  def update_invitation(%Invitation{} = invitation, attrs) do
    invitation
    |> Invitation.changeset(attrs)
    |> Repo.update()
  end

  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  def change_invitation(%Invitation{} = invitation, attrs \\ %{}) do
    Invitation.changeset(invitation, attrs)
  end
end

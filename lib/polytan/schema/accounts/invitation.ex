defmodule Polytan.Schema.Accounts.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :account_id, Ecto.UUID
    field :email, :string
    field :role, :string
    field :token, :string
    field :expires_at, :utc_datetime
    field :invited_by, Ecto.UUID
    field :accepted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:account_id, :email, :role, :token, :expires_at, :invited_by, :accepted_at])
    |> validate_required([
      :account_id,
      :email,
      :role,
      :token,
      :expires_at,
      :invited_by,
      :accepted_at
    ])
  end
end

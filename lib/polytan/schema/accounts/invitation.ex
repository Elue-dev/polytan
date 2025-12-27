defmodule Polytan.Schema.Accounts.Invitation do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{Account, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :email, :string
    field :permissions, :string
    field :token, :string
    field :expires_at, :utc_datetime
    field :accepted_at, :utc_datetime

    belongs_to :account, Account
    belongs_to :inviter, User, foreign_key: :invited_by
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([
      :account_id,
      :email,
      :permissions,
      :token,
      :expires_at,
      :invited_by
    ])
  end
end

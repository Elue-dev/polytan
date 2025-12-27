defmodule Polytan.Schema.Accounts.AccountMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_memberships" do
    field :account_id, Ecto.UUID
    field :user_id, Ecto.UUID
    field :permissions, {:array, :string}
    field :status, :string
    field :invited_at, :utc_datetime
    field :joined_at, :utc_datetime
    field :invited_by, Ecto.UUID
    field :removed_by, Ecto.UUID
    field :removed_reason, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account_membership, attrs) do
    account_membership
    |> cast(attrs, [
      :account_id,
      :user_id,
      :permissions,
      :status,
      :invited_at,
      :joined_at,
      :invited_by,
      :removed_by,
      :removed_reason
    ])
    |> validate_required([
      :account_id,
      :user_id,
      :permissions,
      :status,
      :invited_at,
      :joined_at,
      :invited_by,
      :removed_by,
      :removed_reason
    ])
  end
end

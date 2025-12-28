defmodule Polytan.Schema.Accounts.AccountMembership do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{Account, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_memberships" do
    field :permissions, {:array, :string}
    field :status, :string, default: "active"
    field :invited_at, :utc_datetime
    field :joined_at, :utc_datetime
    field :invited_by, Ecto.UUID
    field :removed_by, Ecto.UUID
    field :removed_reason, :string

    belongs_to :account, Account
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account_membership, attrs) do
    account_membership
    |> cast(attrs, schema_fields(__MODULE__))
    |> validate_required([
      :account_id,
      :user_id
    ])
    |> unique_constraint([:account_id, :user_id])
  end
end

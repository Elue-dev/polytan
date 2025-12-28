defmodule Polytan.Schema.Accounts.Account do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{User, AccountMembership}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :name, :string
    field :status, :string, default: "active"

    belongs_to :owner, User
    has_many :account_memberships, AccountMembership
    has_many :users, through: [:account_memberships, :user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:name, :owner_id])
    |> unique_constraint(:name)
  end
end

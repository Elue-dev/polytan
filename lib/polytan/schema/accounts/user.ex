defmodule Polytan.Schema.Accounts.User do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{Account, AccountMembership}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string

    has_many :owned_accounts, Account, foreign_key: :owner_id
    has_many :account_memberships, AccountMembership
    has_many :accounts, through: [:account_memberships, :account]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:first_name, :last_name, :email, :password])
    |> unique_constraint(:email)
  end
end

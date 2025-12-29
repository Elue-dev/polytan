defmodule Polytan.Schema.Accounts.User do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{Account, AccountMembership}
  alias Polytan.Core.Password

  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :token_version, :integer, default: 0

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
    |> validate_format(:email, @email_regex)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password, Password.hash(password))
    end
  end
end

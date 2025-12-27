defmodule Polytan.Schema.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :name, :string
    field :status, :string
    field :owner_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :status, :owner_id])
    |> validate_required([:name, :status, :owner_id])
  end
end

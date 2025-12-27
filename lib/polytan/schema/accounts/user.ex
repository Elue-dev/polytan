defmodule Polytan.Schema.Accounts.User do
  use Polytan.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:first_name, :last_name, :email, :password])
  end
end

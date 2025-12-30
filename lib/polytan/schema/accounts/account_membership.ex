defmodule Polytan.Schema.Accounts.AccountMembership do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{Account, User}
  alias Polytan.Core.Permissions

  @statuses ~w[active inactive deactivated removed left]

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
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:account_id, :user_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_permissions()
    |> validate_removed_reason()
    |> unique_constraint([:account_id, :user_id])
  end

  defp validate_permissions(changeset) do
    all_permissions = Permissions.get_permissions()
    permissions = get_field(changeset, :permissions)

    IO.puts("PERMSSS: #{inspect(permissions)}")
    invalid = permissions |> Enum.reject(&(&1 in all_permissions))

    case invalid do
      [] ->
        changeset

      _ ->
        add_error(
          changeset,
          :permissions,
          "contains invalid permission(s) #{Enum.join(invalid, ", ")}"
        )
    end
  end

  defp validate_removed_reason(changeset) do
    case get_field(changeset, :status) do
      "removed" ->
        validate_required(changeset, [:removed_reason])

      _ ->
        changeset
    end
  end
end

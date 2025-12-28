defmodule Polytan.Schema.Accounts.Invitation do
  use Polytan.Schema
  import Ecto.Changeset

  alias Polytan.Schema.Accounts.{Account, User}
  alias Polytan.Core.Permissions

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :email, :string
    field :permissions, {:array, :string}
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
    |> validate_required([:email, :permissions])
    |> validate_permissions()
    |> maybe_put_token()
    |> maybe_put_expiration_date()
  end

  defp validate_permissions(changeset) do
    validate_change(changeset, :permissions, &permissions_validator/2)
  end

  defp permissions_validator(_field, permissions) do
    allowed_permissions = Permissions.get_permissions()

    permissions
    |> Enum.uniq()
    |> Enum.filter(fn permission -> permission not in allowed_permissions end)
    |> case do
      [] -> []
      _ -> [permissions: "contains invalid permission(s)"]
    end
  end

  defp maybe_put_token(changeset) do
    case get_change(changeset, :token) do
      nil -> put_token(changeset)
      _ -> changeset
    end
  end

  defp maybe_put_expiration_date(changeset) do
    case get_change(changeset, :expires_at) do
      nil -> put_expiration_date(changeset)
      _ -> changeset
    end
  end

  defp put_token(changeset) do
    token =
      :crypto.strong_rand_bytes(32)
      |> Base.url_encode64(padding: false)

    put_change(changeset, :token, token)
  end

  defp put_expiration_date(changeset) do
    expires_at =
      DateTime.utc_now()
      |> DateTime.add(24 * 60 * 60, :second)
      |> DateTime.truncate(:second)

    put_change(changeset, :expires_at, expires_at)
  end
end

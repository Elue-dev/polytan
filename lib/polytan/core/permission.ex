defmodule Polytan.Core.Permissions do
  alias Polytan.Schema.Accounts.AccountMembership
  import Ecto.Changeset

  @permissions [
    "account.owner",
    "account.admin",
    "account.update",
    "account.member",
    "invite.create",
    "invite.delete",
    "member.remove",
    "member.update"
  ]

  @type permission :: String.t()

  def has_permission?(%AccountMembership{} = membership, permission) do
    elevated_roles = ~w[account.owner account.admin]

    (membership.status == "active" and permission in membership.permissions) or
      Enum.any?(elevated_roles, &(&1 in membership.permissions))
  end

  def has_permission?(_, _), do: false

  def authorize(%{assigns: assigns}, permission) do
    case assigns.current_membership do
      %AccountMembership{} = membership ->
        case has_permission?(membership, permission) do
          true -> :ok
          false -> {:error, :forbidden}
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def validate(changeset) do
    provided_permissions = get_field(changeset, :permissions) || []
    invalid = provided_permissions |> Enum.reject(&(&1 in @permissions))

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

  def get_permissions, do: @permissions
end

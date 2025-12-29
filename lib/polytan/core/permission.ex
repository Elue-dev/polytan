defmodule Polytan.Core.Permissions do
  alias Polytan.Schema.Accounts.AccountMembership

  @permissions [
    "account.admin",
    "account.update",
    "invite.create",
    "invite.delete",
    "member.remove",
    "member.update"
  ]

  @account_owner "account.owner"
  @account_admin "account.admin"

  @type permission :: String.t()

  def has_permission?(%AccountMembership{} = membership, permission) do
    elevated_roles = [@account_owner, @account_admin]

    (membership.status == "active" and permission in membership.permissions) or
      Enum.any?(elevated_roles, &(&1 in membership.permissions))
  end

  def has_permission?(_, _), do: false

  def authorize(%{assigns: assigns}, permission) do
    IO.puts("MEMBERSHIPPPP: #{inspect(assigns.current_membership)}")

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

  def get_permissions, do: @permissions
end

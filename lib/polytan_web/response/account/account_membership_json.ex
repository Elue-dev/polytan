defmodule PolytanWeb.AccountMembershipJSON do
  alias Polytan.Schema.Accounts.AccountMembership, as: Membership

  def index(%{account_memberships: account_memberships}) do
    %{data: for(account_membership <- account_memberships, do: data(account_membership))}
  end

  def show(%{account_membership: account_membership}) do
    %{data: data(account_membership)}
  end

  defp data(%Membership{} = account_membership) do
    %{
      id: account_membership.id,
      account_id: account_membership.account_id,
      user_id: account_membership.user_id,
      permissions: account_membership.permissions,
      status: account_membership.status,
      invited_at: account_membership.invited_at,
      joined_at: account_membership.joined_at,
      invited_by: account_membership.invited_by,
      removed_by: account_membership.removed_by,
      removed_reason: account_membership.removed_reason
    }
  end
end

defmodule Polytan.Context.Account.AccountMemberships do
  import Ecto.Query, warn: false
  alias Polytan.Repo

  alias Polytan.Schema.Accounts.AccountMembership

  def list_account_memberships do
    Repo.all(AccountMembership)
  end

  def get_account_membership(id), do: Repo.get(AccountMembership, id)

  def create_account_membership(attrs) do
    %AccountMembership{}
    |> AccountMembership.changeset(attrs)
    |> Repo.insert()
  end

  def update_account_membership(%AccountMembership{} = account_membership, attrs) do
    account_membership
    |> AccountMembership.changeset(attrs)
    |> Repo.update()
  end

  def delete_account_membership(%AccountMembership{} = account_membership) do
    Repo.delete(account_membership)
  end

  def change_account_membership(%AccountMembership{} = account_membership, attrs \\ %{}) do
    AccountMembership.changeset(account_membership, attrs)
  end
end

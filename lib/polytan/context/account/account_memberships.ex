defmodule Polytan.Context.Account.AccountMemberships do
  import Ecto.Query, warn: false
  alias Polytan.Repo

  alias Polytan.Schema.Accounts.AccountMembership

  def list_account_memberships do
    Repo.all(AccountMembership)
  end

  def get_account_membership(id), do: Repo.get(AccountMembership, id)

  def get_matching_memberships(account_id, user_id) do
    AccountMembership
    |> where(
      [m],
      m.account_id == ^account_id and
        m.user_id == ^user_id
    )
    |> preload(:account)
    |> Repo.all()
  end

  def get_active_membership(account_id, user_id) do
    AccountMembership
    |> where(
      [m],
      m.account_id == ^account_id and
        m.user_id == ^user_id and
        m.status == "active"
    )
    |> preload(:account)
    |> Repo.one()
  end

  def get_inactive_membership(account_id, user_id) do
    AccountMembership
    |> where(
      [m],
      m.account_id == ^account_id and
        m.user_id == ^user_id and
        m.status != "active"
    )
    |> preload(:account)
    |> Repo.one()
  end

  def new(attrs) do
    %AccountMembership{}
    |> AccountMembership.changeset(attrs)
    |> Repo.insert()
  end

  def update(%AccountMembership{} = account_membership, attrs) do
    account_membership
    |> AccountMembership.changeset(attrs)
    |> Repo.update()
  end

  def remove(%AccountMembership{} = account_membership) do
    Repo.delete(account_membership)
  end

  def change(%AccountMembership{} = account_membership, attrs \\ %{}) do
    AccountMembership.changeset(account_membership, attrs)
  end
end

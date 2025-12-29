defmodule Polytan.Context.Account.Users do
  import Ecto.Query, warn: false
  alias Polytan.Repo

  alias Polytan.Schema.Accounts.{User, AccountMembership}

  def list_users do
    Repo.all(User)
  end

  # def get_user(id), do: Repo.get(User, id)

  def get_user(id) do
    User
    |> where(id: ^id)
    |> preload([:owned_accounts])
    |> Repo.one()
  end

  def get_by_email(email) do
    User
    |> where(email: ^email)
    |> preload([:owned_accounts])
    |> Repo.one()
  end

  def load_accounts(id) do
    active_memberships_query =
      from(am in AccountMembership,
        where: am.status == "active",
        preload: [:account]
      )

    User
    |> where(id: ^id)
    |> preload([
      :owned_accounts,
      account_memberships: ^active_memberships_query
    ])
    |> Repo.one()
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end

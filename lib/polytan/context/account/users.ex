defmodule Polytan.Context.Account.Users do
  import Ecto.Query, warn: false
  alias Polytan.Repo

  alias Polytan.Schema.Accounts.User

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
    User
    |> where(id: ^id)
    |> preload([
      :owned_accounts,
      account_memberships: [:account]
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

defmodule Polytan.Context.Account.Accounts do
  import Ecto.Query, warn: false
  alias Polytan.Repo

  alias Polytan.Schema.Accounts.Account
  alias Polytan.Context.Account.{Users, AccountMemberships}

  @account_fields ~w(name owner_id)
  @user_fields ~w(first_name last_name email  password)
  @membership_fields ~w(account_id user_id)

  def list_accounts do
    Repo.all(Account)
  end

  def get_account(id), do: Repo.get(Account, id)

  def get_by_owner_id(owner_id), do: Repo.get_by(Account, owner_id: owner_id)

  def load_account_user(id) do
    Account
    |> where(id: ^id)
    |> preload([:owner, :account_memberships])
    |> Repo.one()
  end

  def create_account_with_owner(params) do
    Repo.transaction(fn ->
      user_params = Map.take(params, @user_fields)
      account_params = Map.take(params, @account_fields)
      membership_params = Map.take(params, @membership_fields)

      with {:ok, user} <- Users.create_user(user_params),
           {:ok, account} <-
             account_params
             |> Map.put("owner_id", user.id)
             |> create_account(),
           {:ok, _membership} <-
             membership_params
             |> Map.put("account_id", account.id)
             |> Map.put("user_id", user.id)
             |> Map.put("permissions", ["account.owner"])
             |> AccountMemberships.new() do
        %{user: user, account: account}
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          Repo.rollback(changeset)

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end

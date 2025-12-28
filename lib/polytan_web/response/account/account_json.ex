defmodule PolytanWeb.AccountJSON do
  alias Polytan.Schema.Accounts.{Account, User, AccountMembership}

  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: account_data(account))}
  end

  def show(%{account: account, user: user, token: token}) do
    %{
      data: %{
        account: account_data(account),
        user: user_data(user),
        access_token: token
      }
    }
  end

  def show(%{account: account, user: user}) do
    %{
      data: %{
        account: account_data(account),
        user: user_data(user)
      }
    }
  end

  def show(%{user: %User{} = user, token: token}) do
    %{
      data: %{
        user: user_data(user),
        accounts: accounts_from_memberships(user.account_memberships),
        access_token: token
      }
    }
  end

  def show(%{user: %User{} = user, current_account: %Account{} = current_account}) do
    %{
      data: %{
        user: user_data(user),
        accounts: accounts_from_memberships(user.account_memberships),
        current_account: current_account_data(current_account, user.account_memberships)
      }
    }
  end

  defp account_data(%Account{} = account) do
    %{
      id: account.id,
      name: account.name,
      status: account.status
    }
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end

  defp accounts_from_memberships(memberships) do
    Enum.map(memberships, fn %AccountMembership{} = membership ->
      %{
        id: membership.account.id,
        name: membership.account.name,
        status: membership.account.status,
        permissions: membership.permissions
      }
    end)
  end

  defp current_account_data(%Account{} = account, memberships) do
    membership =
      Enum.find(memberships, fn m ->
        m.account_id == account.id
      end)

    %{
      id: account.id,
      name: account.name,
      status: account.status,
      permissions: membership.permissions
    }
  end
end

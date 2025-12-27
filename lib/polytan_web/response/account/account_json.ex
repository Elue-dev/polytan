defmodule PolytanWeb.AccountJSON do
  alias Polytan.Schema.Accounts.{Account, User}

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
end

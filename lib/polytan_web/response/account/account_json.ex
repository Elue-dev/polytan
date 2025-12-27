defmodule PolytanWeb.Response.AccountJSON do
  alias Polytan.Schema.Accounts.Account

  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  def show(%{account: account}) do
    %{data: data(account)}
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      name: account.name,
      status: account.status,
      owner_id: account.owner_id
    }
  end
end

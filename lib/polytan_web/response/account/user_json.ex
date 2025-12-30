defmodule PolytanWeb.UserJSON do
  alias Polytan.Schema.Accounts.{User, AccountMembership}

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def show(%{user: user}) do
    %{
      data: %{
        user: data(user),
        accounts: accounts_from_memberships(user.account_memberships)
      }
    }
  end

  defp data(%User{} = user) do
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
end

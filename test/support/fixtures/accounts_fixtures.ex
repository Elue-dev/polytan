defmodule Polytan.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Polytan.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        last_name: "some last_name",
        password: "some password"
      })
      |> Polytan.Accounts.create_user()

    user
  end

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        name: "some name",
        owner_id: "7488a646-e31f-11e4-aace-600308960662",
        status: "some status"
      })
      |> Polytan.Accounts.create_account()

    account
  end
end

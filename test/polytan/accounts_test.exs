defmodule Polytan.AccountsTest do
  use Polytan.DataCase

  alias Polytan.Accounts

  describe "users" do
    alias Polytan.Accounts.User

    import Polytan.AccountsFixtures

    @invalid_attrs %{password: nil, first_name: nil, last_name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{password: "some password", first_name: "some first_name", last_name: "some last_name", email: "some email"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.password == "some password"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.email == "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{password: "some updated password", first_name: "some updated first_name", last_name: "some updated last_name", email: "some updated email"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.password == "some updated password"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "accounts" do
    alias Polytan.Accounts.Account

    import Polytan.AccountsFixtures

    @invalid_attrs %{name: nil, status: nil, owner_id: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{name: "some name", status: "some status", owner_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.name == "some name"
      assert account.status == "some status"
      assert account.owner_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", owner_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.name == "some updated name"
      assert account.status == "some updated status"
      assert account.owner_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "account_memberships" do
    alias Polytan.Accounts.AccountMembership

    import Polytan.AccountsFixtures

    @invalid_attrs %{status: nil, permissions: nil, account_id: nil, user_id: nil, invited_at: nil, joined_at: nil, invited_by: nil, removed_by: nil, removed_reason: nil}

    test "list_account_memberships/0 returns all account_memberships" do
      account_membership = account_membership_fixture()
      assert Accounts.list_account_memberships() == [account_membership]
    end

    test "get_account_membership!/1 returns the account_membership with given id" do
      account_membership = account_membership_fixture()
      assert Accounts.get_account_membership!(account_membership.id) == account_membership
    end

    test "create_account_membership/1 with valid data creates a account_membership" do
      valid_attrs = %{status: "some status", permissions: [], account_id: "7488a646-e31f-11e4-aace-600308960662", user_id: "7488a646-e31f-11e4-aace-600308960662", invited_at: ~U[2025-12-26 15:04:00Z], joined_at: ~U[2025-12-26 15:04:00Z], invited_by: "7488a646-e31f-11e4-aace-600308960662", removed_by: "7488a646-e31f-11e4-aace-600308960662", removed_reason: "some removed_reason"}

      assert {:ok, %AccountMembership{} = account_membership} = Accounts.create_account_membership(valid_attrs)
      assert account_membership.status == "some status"
      assert account_membership.permissions == []
      assert account_membership.account_id == "7488a646-e31f-11e4-aace-600308960662"
      assert account_membership.user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert account_membership.invited_at == ~U[2025-12-26 15:04:00Z]
      assert account_membership.joined_at == ~U[2025-12-26 15:04:00Z]
      assert account_membership.invited_by == "7488a646-e31f-11e4-aace-600308960662"
      assert account_membership.removed_by == "7488a646-e31f-11e4-aace-600308960662"
      assert account_membership.removed_reason == "some removed_reason"
    end

    test "create_account_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account_membership(@invalid_attrs)
    end

    test "update_account_membership/2 with valid data updates the account_membership" do
      account_membership = account_membership_fixture()
      update_attrs = %{status: "some updated status", permissions: [], account_id: "7488a646-e31f-11e4-aace-600308960668", user_id: "7488a646-e31f-11e4-aace-600308960668", invited_at: ~U[2025-12-27 15:04:00Z], joined_at: ~U[2025-12-27 15:04:00Z], invited_by: "7488a646-e31f-11e4-aace-600308960668", removed_by: "7488a646-e31f-11e4-aace-600308960668", removed_reason: "some updated removed_reason"}

      assert {:ok, %AccountMembership{} = account_membership} = Accounts.update_account_membership(account_membership, update_attrs)
      assert account_membership.status == "some updated status"
      assert account_membership.permissions == []
      assert account_membership.account_id == "7488a646-e31f-11e4-aace-600308960668"
      assert account_membership.user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert account_membership.invited_at == ~U[2025-12-27 15:04:00Z]
      assert account_membership.joined_at == ~U[2025-12-27 15:04:00Z]
      assert account_membership.invited_by == "7488a646-e31f-11e4-aace-600308960668"
      assert account_membership.removed_by == "7488a646-e31f-11e4-aace-600308960668"
      assert account_membership.removed_reason == "some updated removed_reason"
    end

    test "update_account_membership/2 with invalid data returns error changeset" do
      account_membership = account_membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account_membership(account_membership, @invalid_attrs)
      assert account_membership == Accounts.get_account_membership!(account_membership.id)
    end

    test "delete_account_membership/1 deletes the account_membership" do
      account_membership = account_membership_fixture()
      assert {:ok, %AccountMembership{}} = Accounts.delete_account_membership(account_membership)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account_membership!(account_membership.id) end
    end

    test "change_account_membership/1 returns a account_membership changeset" do
      account_membership = account_membership_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account_membership(account_membership)
    end
  end
end

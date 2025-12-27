defmodule PolytanWeb.AccountMembershipControllerTest do
  use PolytanWeb.ConnCase

  import Polytan.AccountsFixtures
  alias Polytan.Accounts.AccountMembership

  @create_attrs %{
    status: "some status",
    permissions: [],
    account_id: "7488a646-e31f-11e4-aace-600308960662",
    user_id: "7488a646-e31f-11e4-aace-600308960662",
    invited_at: ~U[2025-12-26 15:04:00Z],
    joined_at: ~U[2025-12-26 15:04:00Z],
    invited_by: "7488a646-e31f-11e4-aace-600308960662",
    removed_by: "7488a646-e31f-11e4-aace-600308960662",
    removed_reason: "some removed_reason"
  }
  @update_attrs %{
    status: "some updated status",
    permissions: [],
    account_id: "7488a646-e31f-11e4-aace-600308960668",
    user_id: "7488a646-e31f-11e4-aace-600308960668",
    invited_at: ~U[2025-12-27 15:04:00Z],
    joined_at: ~U[2025-12-27 15:04:00Z],
    invited_by: "7488a646-e31f-11e4-aace-600308960668",
    removed_by: "7488a646-e31f-11e4-aace-600308960668",
    removed_reason: "some updated removed_reason"
  }
  @invalid_attrs %{status: nil, permissions: nil, account_id: nil, user_id: nil, invited_at: nil, joined_at: nil, invited_by: nil, removed_by: nil, removed_reason: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all account_memberships", %{conn: conn} do
      conn = get(conn, ~p"/api/account_memberships")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create account_membership" do
    test "renders account_membership when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/account_memberships", account_membership: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/account_memberships/#{id}")

      assert %{
               "id" => ^id,
               "account_id" => "7488a646-e31f-11e4-aace-600308960662",
               "invited_at" => "2025-12-26T15:04:00Z",
               "invited_by" => "7488a646-e31f-11e4-aace-600308960662",
               "joined_at" => "2025-12-26T15:04:00Z",
               "permissions" => [],
               "removed_by" => "7488a646-e31f-11e4-aace-600308960662",
               "removed_reason" => "some removed_reason",
               "status" => "some status",
               "user_id" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/account_memberships", account_membership: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update account_membership" do
    setup [:create_account_membership]

    test "renders account_membership when data is valid", %{conn: conn, account_membership: %AccountMembership{id: id} = account_membership} do
      conn = put(conn, ~p"/api/account_memberships/#{account_membership}", account_membership: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/account_memberships/#{id}")

      assert %{
               "id" => ^id,
               "account_id" => "7488a646-e31f-11e4-aace-600308960668",
               "invited_at" => "2025-12-27T15:04:00Z",
               "invited_by" => "7488a646-e31f-11e4-aace-600308960668",
               "joined_at" => "2025-12-27T15:04:00Z",
               "permissions" => [],
               "removed_by" => "7488a646-e31f-11e4-aace-600308960668",
               "removed_reason" => "some updated removed_reason",
               "status" => "some updated status",
               "user_id" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, account_membership: account_membership} do
      conn = put(conn, ~p"/api/account_memberships/#{account_membership}", account_membership: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete account_membership" do
    setup [:create_account_membership]

    test "deletes chosen account_membership", %{conn: conn, account_membership: account_membership} do
      conn = delete(conn, ~p"/api/account_memberships/#{account_membership}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/account_memberships/#{account_membership}")
      end
    end
  end

  defp create_account_membership(_) do
    account_membership = account_membership_fixture()

    %{account_membership: account_membership}
  end
end

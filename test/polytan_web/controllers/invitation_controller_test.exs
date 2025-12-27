defmodule PolytanWeb.InvitationControllerTest do
  use PolytanWeb.ConnCase

  import Polytan.AccountsFixtures
  alias Polytan.Accounts.Invitation

  @create_attrs %{
    token: "some token",
    role: "some role",
    account_id: "7488a646-e31f-11e4-aace-600308960662",
    email: "some email",
    expires_at: ~U[2025-12-26 15:15:00Z],
    invited_by: "7488a646-e31f-11e4-aace-600308960662",
    accepted_at: ~U[2025-12-26 15:15:00Z]
  }
  @update_attrs %{
    token: "some updated token",
    role: "some updated role",
    account_id: "7488a646-e31f-11e4-aace-600308960668",
    email: "some updated email",
    expires_at: ~U[2025-12-27 15:15:00Z],
    invited_by: "7488a646-e31f-11e4-aace-600308960668",
    accepted_at: ~U[2025-12-27 15:15:00Z]
  }
  @invalid_attrs %{token: nil, role: nil, account_id: nil, email: nil, expires_at: nil, invited_by: nil, accepted_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all invitations", %{conn: conn} do
      conn = get(conn, ~p"/api/invitations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create invitation" do
    test "renders invitation when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/invitations", invitation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/invitations/#{id}")

      assert %{
               "id" => ^id,
               "accepted_at" => "2025-12-26T15:15:00Z",
               "account_id" => "7488a646-e31f-11e4-aace-600308960662",
               "email" => "some email",
               "expires_at" => "2025-12-26T15:15:00Z",
               "invited_by" => "7488a646-e31f-11e4-aace-600308960662",
               "role" => "some role",
               "token" => "some token"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/invitations", invitation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update invitation" do
    setup [:create_invitation]

    test "renders invitation when data is valid", %{conn: conn, invitation: %Invitation{id: id} = invitation} do
      conn = put(conn, ~p"/api/invitations/#{invitation}", invitation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/invitations/#{id}")

      assert %{
               "id" => ^id,
               "accepted_at" => "2025-12-27T15:15:00Z",
               "account_id" => "7488a646-e31f-11e4-aace-600308960668",
               "email" => "some updated email",
               "expires_at" => "2025-12-27T15:15:00Z",
               "invited_by" => "7488a646-e31f-11e4-aace-600308960668",
               "role" => "some updated role",
               "token" => "some updated token"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, invitation: invitation} do
      conn = put(conn, ~p"/api/invitations/#{invitation}", invitation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete invitation" do
    setup [:create_invitation]

    test "deletes chosen invitation", %{conn: conn, invitation: invitation} do
      conn = delete(conn, ~p"/api/invitations/#{invitation}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/invitations/#{invitation}")
      end
    end
  end

  defp create_invitation(_) do
    invitation = invitation_fixture()

    %{invitation: invitation}
  end
end

defmodule PolytanWeb.AccountMembershipController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.AccountMemberships, as: Memberships
  alias Polytan.Schema.Accounts.AccountMembership

  action_fallback PolytanWeb.FallbackController

  def index(conn, _params) do
    account_memberships = Memberships.list_account_memberships()
    render(conn, :index, account_memberships: account_memberships)
  end

  def create(conn, %{"account_membership" => account_membership_params}) do
    with {:ok, %AccountMembership{} = account_membership} <-
           Memberships.create_account_membership(account_membership_params) do
      conn
      |> put_status(:created)
      |> render(:show, account_membership: account_membership)
    end
  end

  def show(conn, %{"id" => id}) do
    account_membership = Memberships.get_account_membership(id)
    render(conn, :show, account_membership: account_membership)
  end

  def update(conn, %{"id" => id, "account_membership" => account_membership_params}) do
    account_membership = Memberships.get_account_membership(id)

    with {:ok, %AccountMembership{} = account_membership} <-
           Memberships.update_account_membership(
             account_membership,
             account_membership_params
           ) do
      render(conn, :show, account_membership: account_membership)
    end
  end

  def delete(conn, %{"id" => id}) do
    account_membership = Memberships.get_account_membership(id)

    with {:ok, %AccountMembership{}} <- Memberships.delete_account_membership(account_membership) do
      send_resp(conn, :no_content, "")
    end
  end
end

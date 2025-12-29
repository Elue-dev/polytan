defmodule PolytanWeb.AccountMembershipController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.AccountMemberships, as: Memberships
  alias Polytan.Schema.Accounts.AccountMembership
  alias Polytan.Core.Permissions
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  plug :authorize_action when action in [:remove_membership, :update_membership]

  def index(conn, _params) do
    account_memberships = Memberships.list_account_memberships()
    render(conn, :index, account_memberships: account_memberships)
  end

  def remove_membership(conn, %{"user_id" => user_id} = params) do
    %{
      current_account: current_account,
      current_user: current_user
    } = conn.assigns

    update_params =
      params
      |> Map.put("status", "removed")
      |> Map.put("removed_by", current_user.id)
      |> Map.put("removed_reason", params["removed_reason"])

    case Memberships.get_active_membership(current_account.id, user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not a member"})

      membership ->
        with true <- ensure_not_an_owner(current_account.id, user_id),
             {:ok, %AccountMembership{}} <-
               Memberships.update_account_membership(membership, update_params) do
          conn
          |> put_status(:ok)
          |> json(%{message: "User has been removed"})
        else
          {:error, :user_is_owner} ->
            conn
            |> put_status(:forbidden)
            |> json(%{
              error: "User is the account owner. Transfer ownership before removing this user."
            })

          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
        end
    end
  end

  defp ensure_not_an_owner(account_id, user_id) do
    case Memberships.get_active_membership(account_id, user_id) do
      nil ->
        true

      membership ->
        case "account.owner" not in membership.permissions do
          true -> true
          false -> {:error, :user_is_owner}
        end
    end
  end

  defp authorize_action(conn, _opts) do
    permission =
      case conn.private.phoenix_action do
        :remove_membership -> "member.remove"
        :update_membership -> "member.update"
      end

    case Permissions.authorize(conn, permission) do
      :ok ->
        conn

      {:error, reason} ->
        Response.permission_response(conn, reason)
    end
  end
end

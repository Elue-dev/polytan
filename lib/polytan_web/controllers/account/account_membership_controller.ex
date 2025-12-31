defmodule PolytanWeb.AccountMembershipController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.AccountMemberships, as: Memberships
  alias Polytan.Schema.Accounts.AccountMembership
  alias Polytan.Core.{Permissions, RequestValidator}
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  plug :authorize_action when action in ~w[remove_membership update_membership]a
  plug :validate_action when action in ~w[update_permissions]a

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

    with {:ok, membership} <- is_a_member?(current_account.id, user_id),
         true <- ensure_not_an_owner(current_account.id, user_id),
         {:ok, %AccountMembership{}} <-
           Memberships.update(membership, update_params) do
      conn
      |> put_status(:ok)
      |> json(%{message: "User has been removed"})
    else
      {:error, :not_a_member} ->
        {:error, :not_a_member}

      false ->
        Response.send_error(
          conn,
          :forbidden,
          "User is the account owner. Transfer ownership before removing this user."
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def update_permissions(conn, %{"user_id" => user_id} = params) do
    current_account = conn.assigns.current_account

    with true <- "account.owner" not in params["permissions"],
         {:ok, membership} <- is_a_member?(current_account.id, user_id),
         {:ok, _} <-
           Memberships.update(membership, %{permissions: params["permissions"]}) do
      Response.respond(conn, :ok, "Permissions updated successfully")
    else
      false ->
        {:error, "You can't add ownership permission. Ownership must be transferred."}

      {:error, :invalid_permissions} ->
        {:error, "Invalid permission(s) detected"}

      {:error, :not_a_member} ->
        {:error, :not_a_member}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp is_a_member?(account_id, user_id) do
    case Memberships.get_active_membership(account_id, user_id) do
      nil -> {:error, :not_a_member}
      membership -> {:ok, membership}
    end
  end

  defp ensure_not_an_owner(account_id, user_id) do
    case Memberships.get_active_membership(account_id, user_id) do
      nil -> true
      membership -> "account.owner" not in membership.permissions
    end
  end

  defp validate_action(conn, _opts) do
    fields = action_fields(conn, :validate)

    case RequestValidator.validate_required(conn.params, fields) do
      {:ok, _} -> conn
      {:error, errors} -> Response.send_errors(conn, errors)
    end
  end

  defp authorize_action(conn, _opts) do
    permission = action_fields(conn, :authorize)

    case Permissions.authorize(conn, permission) do
      :ok -> conn
      {:error, reason} -> Response.permission_response(conn, reason)
    end
  end

  defp action_fields(conn, :authorize) do
    case conn.private.phoenix_action do
      :remove_membership -> "member.remove"
      :update_membership -> "member.update"
    end
  end

  defp action_fields(conn, :validate) do
    case conn.private.phoenix_action do
      :update_permissions -> ~w[permissions]
    end
  end
end

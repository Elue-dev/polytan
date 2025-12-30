defmodule PolytanWeb.Plugs.SetAccount do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias PolytanWeb.Auth.Guardian
  alias Polytan.Context.Account.AccountMemberships

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Guardian.verify_user_token(token),
         {:ok, account_id} <- get_account_id(conn),
         membership when not is_nil(membership) <-
           AccountMemberships.get_active_membership(account_id, user.id) do
      conn
      |> assign(:current_user, user)
      |> assign(:current_account, membership.account)
      |> assign(:current_membership, membership)
      |> assign(:current_user_token, token)
    else
      nil ->
        respond(conn, :forbidden, "Forbidden")

      _ ->
        respond(conn, :unauthorized, "Unauthorized")
    end
  end

  defp get_account_id(conn) do
    case get_req_header(conn, "x-account-id") do
      [account_id] -> {:ok, account_id}
      _ -> {:error, :missing_account_id}
    end
  end

  defp invalidate_conn(conn) do
    conn
    |> assign(:current_user, nil)
    |> assign(:current_account, nil)
    |> assign(:current_membership, nil)
  end

  defp respond(conn, status, message) do
    invalidate_conn(conn)

    conn
    |> put_status(status)
    |> json(%{error: message})
    |> halt()
  end
end

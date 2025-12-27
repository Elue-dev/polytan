defmodule PolytanWeb.Plugs.SetAccount do
  import Plug.Conn
  alias PolytanWeb.Auth.Guardian

  alias Polytan.Context.Account.Accounts

  def init(_opts), do: []

  def call(conn, _opts) do
    if conn.assigns[:account], do: halt(conn)

    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case Guardian.verify_user_token(token) do
          {:ok, account} ->
            user = Accounts.load_account_user(account.id)
            current_account = Map.merge(account, user)
            assign(conn, :current_account, current_account)

          :error ->
            assign(conn, :current_account, nil)
        end

      _ ->
        assign(conn, :current_account, nil)
    end
  end
end

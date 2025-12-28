defmodule PolytanWeb.Plugs.ValidateActiveAccount do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias Polytan.Schema.Accounts.{Account, AccountMembership}

  require Logger

  def init(opts), do: opts

  def call(
        %{
          assigns: %{
            current_account: %Account{status: "active"},
            current_membership: %AccountMembership{status: "active"}
          }
        } = conn,
        _opts
      ) do
    conn
  end

  def call(conn, _opts) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Account inactive"})
    |> halt()
  end
end

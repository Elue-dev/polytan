defmodule PolytanWeb.Plugs.ValidateActiveAccount do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def(init(opts), do: opts)

  def call(conn, _opts) do
    case conn do
      %{assigns: %{account: %{status: :active}}} ->
        conn

      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Account inactive"})
        |> halt()
    end
  end
end

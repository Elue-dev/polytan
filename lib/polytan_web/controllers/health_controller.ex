defmodule PolytanWeb.HealthController do
  use PolytanWeb, :controller

  def ping(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "pong"})
  end
end

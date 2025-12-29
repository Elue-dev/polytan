defmodule PolytanWeb.Auth.GuardianErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    {status, body} =
      case type do
        :no_resource_found -> {401, %{error: "Your session has expired. Please log in again"}}
        :unauthenticated -> {401, %{error: "Unauthenticated"}}
        :invalid_token -> {401, %{error: "Invalid authentication token"}}
        _ -> {401, %{error: "Unauthorized"}}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end

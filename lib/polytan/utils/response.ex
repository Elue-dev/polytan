defmodule Polytan.Utils.Response do
  use PolytanWeb, :controller

  def permission_response(conn, reason) do
    conn
    |> put_status(status_for(reason))
    |> json(%{error: Atom.to_string(reason)})
    |> halt()
  end

  def send_error(conn, status, error) do
    conn
    |> put_status(status)
    |> json(%{error: error})
  end

  def respond(conn, status, message) when is_binary(message) do
    conn
    |> put_status(status)
    |> json(%{message: message})
  end

  def respond(conn, status, json) do
    conn
    |> put_status(status)
    |> json(json)
  end

  defp status_for(:forbidden), do: :forbidden
  defp status_for(:unauthorized), do: :unauthorized
end

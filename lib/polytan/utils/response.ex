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

  def send_errors(conn, errors) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: errors})
    |> halt()
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

  def required(conn, params, fields) do
    missing = params -- fields

    error_message =
      Enum.map(missing, fn field ->
        %{error: "#{field} is required"}
      end)

    conn
    |> put_status(:bad_request)
    |> json(%{error: error_message})
  end

  defp status_for(:forbidden), do: :forbidden
  defp status_for(:unauthorized), do: :unauthorized
end

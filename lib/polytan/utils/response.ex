defmodule Polytan.Utils.Response do
  use PolytanWeb, :controller

  def permission_response(conn, reason) do
    conn
    |> put_status(status_for(reason))
    |> json(%{error: Atom.to_string(reason)})
    |> halt()
  end

  defp status_for(:forbidden), do: :forbidden
  defp status_for(:unauthorized), do: :unauthorized
end

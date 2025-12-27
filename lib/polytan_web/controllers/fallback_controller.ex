defmodule PolytanWeb.FallbackController do
  use PolytanWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :unauthenticated}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Unauthenticated"})
  end

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid email or password"})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Not Found"})
  end
end

defmodule PolytanWeb.FallbackController do
  use PolytanWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PolytanWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: PolytanWeb.ErrorHTML, json: PolytanWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Bad request"})
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

  def call(conn, {:error, :invalid_invitation}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid or expired invitation"})
  end

  def call(conn, {:error, :no_active_accounts}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: "You don’t belong to any active organization. Ask an administrator to invite you."
    })
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Forbidden"})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Not Found"})
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "Internal server error"})
  end
end

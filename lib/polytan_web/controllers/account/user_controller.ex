defmodule PolytanWeb.UserController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.Users
  alias Polytan.Schema.Accounts.User
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  # TODO: implement token blacklist, to invalidate only a specific token
  # but others remain valid in cases where user is logged into multiple devices

  def logout(conn, _params) do
  end

  def logout_all_accounts(conn, _params) do
    user = conn.assigns.current_user

    with {:ok, _} <- revoke_current_token(user) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Logged out"})
    else
      {:error, :user_not_found} -> Response.send_error(conn, :not_found, "User not found")
      {:error, reason} -> {:error, reason}
    end
  end

  defp revoke_current_token(user) do
    case Users.get_user(user.id) do
      nil -> {:error, :user_not_found}
      %User{} = user -> Users.update_user(user, %{token_version: user.token_version + 1})
    end
  end
end

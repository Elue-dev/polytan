defmodule PolytanWeb.UserController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.Users
  alias Polytan.Schema.Accounts.User
  alias PolytanWeb.Auth.Guardian
  alias PolytanWeb.Auth.TokenBlacklist
  alias Polytan.Utils.Response

  action_fallback PolytanWeb.FallbackController

  def me(conn, _params) do
    case {conn.assigns.current_account, conn.assigns.current_user} do
      {nil, _} ->
        {:error, :unauthenticated}

      {_current_account, current_user} ->
        user = Users.load_accounts(current_user.id)

        render(conn, :show, %{user: user})
    end
  end

  def logout(conn, _params) do
    token = conn.assigns.current_user_token

    case revoke_token(token) do
      {:ok, :revoked} -> :ok
      {:error, _reason} -> :ok
    end

    Response.respond(conn, :ok, "Logged out successfully")
  end

  def logout_all_accounts(conn, _params) do
    user = conn.assigns.current_user

    with {:ok, _} <- revoke_all_tokens(user) do
      # TODO: send socket event to clients
      Response.respond(conn, :ok, "Logged out from all devices")
    else
      {:error, :user_not_found} -> {:error, :user_not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp revoke_token(token) do
    case Guardian.decode_and_verify(token, %{}) do
      {:ok, %{"jti" => jti, "exp" => exp}} ->
        expires_at = DateTime.from_unix!(exp)
        TokenBlacklist.revoke(jti, expires_at)
        {:ok, :revoked}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp revoke_all_tokens(user) do
    case Users.get_user(user.id) do
      nil -> {:error, :user_not_found}
      %User{} = user -> Users.update_user(user, %{token_version: user.token_version + 1})
    end
  end
end

defmodule PolytanWeb.AccountController do
  use PolytanWeb, :controller

  alias Polytan.Context.Account.{Accounts, Users}
  alias Polytan.Schema.Accounts.{Account, User}
  alias PolytanWeb.Auth.Guardian
  alias Polytan.Core.Password

  action_fallback PolytanWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def register(conn, params) do
    case Accounts.create_account_with_owner(params) do
      {:ok, %{user: user, account: account}} ->
        token = Guardian.create_token(account, :access)

        conn
        |> put_status(:created)
        |> render(:show, account: account, user: user, token: token)

      {:error, _step, reason, _changes} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    with %User{} = user <- Users.get_by_email(email),
         %Account{} = account <- Accounts.get_by_owner_id(user.id),
         true <- Password.validate(password, user.password),
         {:ok, token} <- Guardian.create_token(account, :access) do
      conn
      |> put_status(:ok)
      |> render(:show, account: account, user: user, token: token)
    else
      _ ->
        {:error, :invalid_credentials}
    end
  end

  def me(conn, _params) do
    case conn.assigns.current_account do
      nil ->
        {:error, :unauthenticated}

      account ->
        render(conn, :show, account: account.account, user: account.user)
    end
  end

  def update(conn, %{"id" => id} = params) do
    account = Accounts.get_account(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end

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
      {:ok, %{user: user, account: _account}} ->
        token = Guardian.create_token(user, :access)
        user = Users.load_accounts(user.id)

        conn
        |> put_status(:created)
        |> render(:show, user: user, token: token)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    with %User{} = user <- Users.get_by_email(email),
         true <- Password.validate(password, user.password),
         {:ok, token} <- Guardian.create_token(user, :access),
         %User{} = user <- Users.load_accounts(user.id) do
      conn
      |> put_status(:ok)
      |> render(:show, user: user, token: token)
    else
      _ ->
        {:error, :invalid_credentials}
    end
  end

  def login(_conn, _params) do
    {:error, :bad_request}
  end

  def me(conn, _params) do
    case {conn.assigns.current_account, conn.assigns.current_user} do
      {nil, _} ->
        {:error, :unauthenticated}

      {current_account, current_user} ->
        user = Users.load_accounts(current_user.id)

        render(conn, :show, %{
          user: user,
          current_account: current_account
        })
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

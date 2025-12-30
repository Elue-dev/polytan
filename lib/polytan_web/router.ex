defmodule PolytanWeb.Router do
  use PolytanWeb, :router
  use Plug.ErrorHandler

  defdelegate handle_errors(conn, error), to: PolytanWeb.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]

    # plug OpenApiSpex.Plug.PutApiSpec, module: PolytanWeb.ApiSpec
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug PolytanWeb.Auth.Pipeline
    plug PolytanWeb.Plugs.SetAccount
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {PolytanWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", PolytanWeb do
    pipe_through :api

    get "/ping", HealthController, :ping

    scope "/auth" do
      post "/register", AccountController, :register
      post "/login", AccountController, :login
    end
  end

  scope "/api", PolytanWeb do
    pipe_through ~w[api auth]a

    scope "/auth" do
      post "/logout", UserController, :logout
      post "/logout/all", UserController, :logout_all_accounts
    end
  end

  scope "/api", PolytanWeb do
    pipe_through ~w[api auth]a

    get "/me", UserController, :me
    get "/invitations", InvitationController, :list
    post "/invitations", InvitationController, :create
    delete "/invitations/:id", InvitationController, :delete
    patch "/memberships/:user_id/permissions", AccountMembershipController, :update_permissions
    post "/memberships/:user_id/remove", AccountMembershipController, :remove_membership
  end

  scope "/api", PolytanWeb do
    pipe_through ~w[api auth]a

    scope "/accounts" do
      post "/transfer-ownership", AccountController, :transfer_ownership
    end
  end

  scope "/api", PolytanWeb do
    pipe_through :api

    post "/invitations/accept/:id", InvitationController, :accept
  end

  if Application.compile_env(:polytan, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

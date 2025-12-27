defmodule PolytanWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :polytan,
    module: PolytanWeb.Auth.Guardian,
    error_handler: PolytanWeb.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end

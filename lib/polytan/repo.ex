defmodule Polytan.Repo do
  use Ecto.Repo,
    otp_app: :polytan,
    adapter: Ecto.Adapters.Postgres
end

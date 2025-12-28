import Config

config :polytan,
  ecto_repos: [Polytan.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :polytan, PolytanWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PolytanWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Polytan.PubSub,
  live_view: [signing_salt: "nU42mWmh"]

config :polytan, Oban,
  repo: Polytan.Repo,
  queues: [default: 10],
  plugins: [Oban.Plugins.Pruner]

config :polytan, Polytan.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"

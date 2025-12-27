import Config

config :polytan, Polytan.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "polytan",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :polytan, PolytanWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "4000")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "uETJByc3NGTLZUl+FhxcEVgmsttb89iqLdkPCoeDXNNBcyjh9l3EpWivrA/nfDYY",
  watchers: []

config :polytan, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false

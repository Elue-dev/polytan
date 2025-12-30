defmodule Polytan.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PolytanWeb.Telemetry,
      Polytan.Repo,
      {DNSCluster, query: Application.get_env(:polytan, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Polytan.PubSub},
      PolytanWeb.Auth.TokenBlacklist,
      PolytanWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Polytan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PolytanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

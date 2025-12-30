defmodule PolytanWeb.Auth.TokenBlacklistProcess do
  use GenServer
  require Logger

  @table_name :token_blacklist
  @cleanup_interval :timer.hours(1)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    table =
      :ets.new(
        @table_name,
        [:set, :named_table, :public, read_concurrency: true, write_concurrency: true]
      )

    schedule_cleanup()

    {:ok, %{table: table}}
  end

  def revoke(jti, expires_at) when is_binary(jti) do
    exp_timestamp = DateTime.to_unix(expires_at)
    :ets.insert(@table_name, {jti, exp_timestamp})
    :ok
  end

  def revoked?(jti) when is_binary(jti) do
    case :ets.lookup(@table_name, jti) do
      [{^jti, exp_timestamp}] ->
        now = DateTime.to_unix(DateTime.utc_now())

        if now < exp_timestamp do
          true
        else
          :ets.delete(@table_name, jti)
          false
        end

      [] ->
        false
    end
  end

  def cleanup_expired do
    GenServer.cast(__MODULE__, :cleanup)
  end

  @impl true
  def handle_cast(:cleanup, state) do
    now = DateTime.to_unix(DateTime.utc_now())

    :ets.select_delete(@table_name, [
      {{:"$1", :"$2"}, [{:<, :"$2", now}], [true]}
    ])

    schedule_cleanup()
    {:noreply, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    handle_cast(:cleanup, state)
  end

  defp schedule_cleanup() do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end
end

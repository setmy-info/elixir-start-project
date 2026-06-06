defmodule SetmyInfo.CalculatorRest.RateLimiter do
  @moduledoc """
  ETS-backed fixed-window rate limiter.

  Counts requests per remote IP address within 60-second windows.
  A single GenServer owns the ETS table and prunes stale entries every
  two minutes.

  The request limit defaults to 100 per window and can be overridden in
  application config:

      config :calculator_app, rate_limit_max_requests: 200

  ## Usage

      case RateLimiter.check_rate("203.0.113.5") do
        :ok              -> # proceed
        {:error, :rate_limited} -> # return 429
      end
  """

  use GenServer

  @table :rate_limiter
  @window_seconds 60

  # ── Public API ────────────────────────────────────────────────────────────

  @doc "Start the rate limiter GenServer (called by the application supervisor)."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Record a request for `ip_address` and return `:ok` or `{:error, :rate_limited}`.

  If the ETS table does not exist (rate limiter not started), the request is
  allowed through so that the plug does not crash in environments where the
  server is not running.
  """
  @spec check_rate(String.t()) :: :ok | {:error, :rate_limited}
  def check_rate(ip_address) when is_binary(ip_address) do
    if :ets.whereis(@table) == :undefined do
      :ok
    else
      key = {ip_address, current_window()}
      count = :ets.update_counter(@table, key, {2, 1}, {key, 0})

      if count <= max_requests() do
        :ok
      else
        {:error, :rate_limited}
      end
    end
  end

  # ── GenServer callbacks ───────────────────────────────────────────────────

  @impl GenServer
  def init(_opts) do
    :ets.new(@table, [:named_table, :public, :set])
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    prune_stale()
    schedule_cleanup()
    {:noreply, state}
  end

  # ── Private helpers ───────────────────────────────────────────────────────

  defp max_requests do
    Application.get_env(:calculator_app, :rate_limit_max_requests, 100)
  end

  defp current_window do
    div(System.system_time(:second), @window_seconds)
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, :timer.minutes(2))
  end

  defp prune_stale do
    stale_before = current_window() - 2

    :ets.select_delete(@table, [
      {{{:"$1", :"$2"}, :_}, [{:<, :"$2", stale_before}], [true]}
    ])
  end
end

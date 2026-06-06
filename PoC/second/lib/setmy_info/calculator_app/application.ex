defmodule SetmyInfo.CalculatorApp.Application do
  use Application

  @moduledoc """
  Application supervisor for the calculator project.

  When `:server` is enabled in the application environment, it starts
  the full service stack in this order:

  1. `ServiceRegistry` — Elixir `Registry` for via-tuple process lookup
  2. `ServiceSupervisor` — sub-supervisor owning `TaskSupervisor`, `Cache`, `History`
  3. `RateLimiter`       — ETS-backed per-IP rate limiter
  4. `Plug.Cowboy`       — shared HTTP server (REST + GraphQL + static)

  After the supervisor tree is up, `TelemetryHandler.attach/0` wires the
  `Plug.Telemetry` stop-event handler so HTTP metrics are logged.
  """

  alias SetmyInfo.CalculatorApp.{ServiceRegistry, ServiceSupervisor, TelemetryHandler}
  alias SetmyInfo.CalculatorRest.{RateLimiter, Router}

  @impl true
  def start(_type, _args) do
    ensure_log_directory!()
    ensure_file_logging!()

    port = Application.fetch_env!(:calculator_app, :rest_port)

    server_children =
      if Application.get_env(:calculator_app, :server, false) do
        [
          {Registry, keys: :unique, name: ServiceRegistry},
          ServiceSupervisor,
          RateLimiter,
          {Plug.Cowboy, scheme: :http, plug: Router, options: [port: port]}
        ]
      else
        []
      end

    children = server_children ++ db_children()

    result =
      Supervisor.start_link(children,
        strategy: :one_for_one,
        name: SetmyInfo.CalculatorApp.Supervisor
      )

    TelemetryHandler.attach()
    result
  end

  defp db_children do
    if Application.get_env(:calculator_app, SetmyInfo.Ecto.Repo) do
      [SetmyInfo.Ecto.Repo]
    else
      []
    end
  end

  @doc false
  defp ensure_log_directory! do
    log_dir = Application.fetch_env!(:calculator_app, :log_dir)
    File.mkdir_p!(Path.expand(log_dir, File.cwd!()))
  end

  @doc false
  defp ensure_file_logging! do
    LoggerBackends.add({LoggerFileBackend, :calculator_app_log})
  rescue
    _ -> :ok
  end
end

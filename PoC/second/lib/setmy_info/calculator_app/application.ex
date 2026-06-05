defmodule SetmyInfo.CalculatorApp.Application do
  use Application

  @moduledoc """
  Application supervisor for the calculator project.

  When `:server` is enabled in the application environment, it starts the
  shared HTTP endpoint that serves REST, GraphQL, Swagger, and static assets.
  """

  @impl true
  def start(_type, _args) do
    ensure_log_directory!()
    ensure_file_logging!()

    port = Application.fetch_env!(:calculator_app, :rest_port)

    children =
      if Application.get_env(:calculator_app, :server, false) do
        [
          {Plug.Cowboy,
           scheme: :http, plug: SetmyInfo.CalculatorRest.Router, options: [port: port]}
        ]
      else
        []
      end

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: SetmyInfo.CalculatorApp.Supervisor
    )
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

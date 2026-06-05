defmodule SetmyInfo.CoreLogic.Application do
  @moduledoc """
  OTP Application entry point for SetmyInfo.CoreLogic.

  Starts the supervision tree for all core business logic services.
  This app is depended on by runtime_engine, graphql_api, and cli.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [SetmyInfo.CoreLogic.Supervisor] ++
        db_children()

    opts = [strategy: :one_for_one, name: SetmyInfo.CoreLogic.ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end

  # Start the Repo only when a database URL / credentials are configured.
  # This lets the app run without a database in development and CI.
  defp db_children do
    if Application.get_env(:core_logic, SetmyInfo.CoreLogic.Repo) do
      [SetmyInfo.CoreLogic.Repo]
    else
      []
    end
  end
end

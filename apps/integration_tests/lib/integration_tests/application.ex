defmodule SetmyInfo.IntegrationTests.Application do
  @moduledoc """
  Minimal OTP application for the integration test suite.

  No permanent processes are started here. The dependent applications
  (core_logic, runtime_engine) are started automatically by Mix when
  running integration_tests tests, ensuring a real OTP environment.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: SetmyInfo.IntegrationTests.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

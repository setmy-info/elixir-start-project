defmodule SetmyInfo.RuntimeEngine.Application do
  @moduledoc """
  OTP Application entry point for SetmyInfo.RuntimeEngine.

  Starts a Registry for named worker lookup, then the main Supervisor
  which owns the DynamicSupervisor (for Worker processes) and the Loader
  (tracks loaded modules via ETS).
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: SetmyInfo.RuntimeEngine.Registry},
      SetmyInfo.RuntimeEngine.Supervisor
    ]

    opts = [strategy: :one_for_one, name: SetmyInfo.RuntimeEngine.ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end
end

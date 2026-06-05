defmodule SetmyInfo.RuntimeEngine.Supervisor do
  @moduledoc """
  Root supervisor for SetmyInfo.RuntimeEngine.

  Owns:
  - DynamicSupervisor: starts/stops Worker processes on demand
  - Loader: GenServer that tracks loaded modules in ETS
  """

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # ModuleRegistry must start first — Loader reads from its ETS table.
      SetmyInfo.RuntimeEngine.ModuleRegistry,
      {DynamicSupervisor,
       name: SetmyInfo.RuntimeEngine.DynamicSupervisor, strategy: :one_for_one},
      SetmyInfo.RuntimeEngine.Loader
    ]

    # rest_for_one ordering:
    #   ModuleRegistry crash → DynamicSupervisor + Loader restart (Workers terminated,
    #     ETS rebuilt cleanly on Loader restart).
    #   DynamicSupervisor crash → Loader restarts; it reconciles with Registry so any
    #     surviving Workers are re-tracked.
    #   Loader crash → only Loader restarts; Workers survive, Loader reconciles.
    Supervisor.init(children, strategy: :rest_for_one)
  end
end

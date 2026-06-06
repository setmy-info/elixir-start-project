defmodule SetmyInfo.CalculatorApp.ServiceSupervisor do
  @moduledoc """
  One-for-one supervisor that owns the service layer.

  Supervises:
  - `Task.Supervisor` — for supervised parallel computation
  - `SetmyInfo.CalculatorApp.Cache` — ETS-backed result cache
  - `SetmyInfo.CalculatorApp.History` — GenServer calculation history
  - `SetmyInfo.CalculatorApp.RunningTotal` — Agent running sum

  Started as a child of `SetmyInfo.CalculatorApp.Application` after the
  `SetmyInfo.CalculatorApp.ServiceRegistry` Registry so that `History`
  can register itself via `{:via, Registry, ...}` on startup.

  Demonstrates multi-level supervision: the application supervisor owns
  this supervisor, which in turn owns the individual service processes.
  """

  use Supervisor

  alias SetmyInfo.CalculatorApp.{Cache, History, RunningTotal, TaskSupervisor}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      {Task.Supervisor, name: TaskSupervisor},
      Cache,
      History,
      RunningTotal
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

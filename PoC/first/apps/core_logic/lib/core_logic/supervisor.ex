defmodule SetmyInfo.CoreLogic.Supervisor do
  @moduledoc """
  Root supervisor for the SetmyInfo.CoreLogic application.

  Uses one_for_one strategy: a failing child does not bring down siblings.
  Add core business logic workers as children here.
  """

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = []

    Supervisor.init(children, strategy: :one_for_one)
  end
end

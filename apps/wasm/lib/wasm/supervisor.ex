defmodule SetmyInfo.Wasm.Supervisor do
  @moduledoc """
  Supervisor for the WASM engine components.

  When a real WASM runtime (e.g. wasmex) is added, start its
  resource manager here so WASM modules are preloaded at startup.
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

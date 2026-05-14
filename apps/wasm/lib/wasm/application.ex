defmodule SetmyInfo.Wasm.Application do
  @moduledoc """
  OTP Application for the WASM execution engine (stub).

  This application serves as the integration point for a future WASM
  runtime engine. When wasmex or Extism is added as a dependency,
  the engine supervisor and NIF loaders will be started here.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SetmyInfo.Wasm.Supervisor
    ]

    opts = [strategy: :one_for_one, name: SetmyInfo.Wasm.ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end
end

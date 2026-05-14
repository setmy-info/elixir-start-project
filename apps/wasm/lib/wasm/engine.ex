defmodule SetmyInfo.Wasm.Engine do
  @moduledoc """
  Stub for a future WASM execution engine.

  Architecture notes for future implementation:
  - wasmex (Elixir binding to Wasmer via Rust NIF):
      {:wasmex, "~> 0.9"}
  - Extism (WASM plugin system with many language SDKs):
      {:extism, "~> 1.0"}
  - Custom NIF via Rustler:
      {:rustler, "~> 0.30"}

  Each backend would implement the SetmyInfo.RuntimeEngine.Module behaviour,
  meaning the Loader/Worker/Executor layer requires zero changes.
  """

  @type module_ref :: reference()

  @doc "Load a WASM binary and return an opaque module reference."
  @spec load(binary()) :: {:ok, module_ref()} | {:error, :not_implemented}
  def load(_wasm_bytes), do: {:error, :not_implemented}

  @doc "Execute a named export function in a loaded WASM module."
  @spec execute(module_ref(), String.t(), [term()]) :: {:ok, term()} | {:error, term()}
  def execute(_module_ref, _function, _args), do: {:error, :not_implemented}

  @doc "Release resources held by a loaded WASM module."
  @spec release(module_ref()) :: :ok
  def release(_module_ref), do: :ok
end

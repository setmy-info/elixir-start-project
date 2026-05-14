defmodule SetmyInfo.RuntimeEngine.Module do
  @moduledoc """
  Behaviour that all pluggable runtime modules must implement.

  Implementing this behaviour allows a module to be loaded into the
  SetmyInfo.RuntimeEngine and have its functions dispatched via Worker processes.

  Future engines (Lua, WASM) will implement this same interface,
  keeping the Loader/Executor/Worker layer engine-agnostic.
  """

  @doc "Returns the unique name identifying this module."
  @callback name() :: atom()

  @doc "Executes a named function with the given arguments."
  @callback execute(function :: atom(), args :: [term()]) ::
              {:ok, term()} | {:error, term()}
end

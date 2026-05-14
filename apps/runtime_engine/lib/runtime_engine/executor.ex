defmodule SetmyInfo.RuntimeEngine.Executor do
  @moduledoc """
  High-level facade for the load → execute → release lifecycle.

  Callers that only need a single result should prefer `run_and_release/3`,
  which cleans up resources automatically.  For repeated calls to the same
  module, use `run/3` and call `SetmyInfo.RuntimeEngine.Loader.release/1` explicitly
  when done.
  """

  alias SetmyInfo.RuntimeEngine.{Loader, Worker}

  @doc """
  Loads the module if needed and executes the function, leaving the module
  loaded for subsequent calls.
  """
  @spec run(atom(), atom(), [term()]) :: {:ok, term()} | {:error, term()}
  def run(module_name, function, args) do
    with {:ok, _pid} <- Loader.load(module_name) do
      Worker.execute(module_name, function, args)
    end
  end

  @doc """
  Loads the module, executes the function, then releases the module.
  The full load → execute → release lifecycle in a single call.
  """
  @spec run_and_release(atom(), atom(), [term()]) :: {:ok, term()} | {:error, term()}
  def run_and_release(module_name, function, args) do
    with {:ok, _pid} <- Loader.load(module_name),
         result <- Worker.execute(module_name, function, args),
         :ok <- Loader.release(module_name) do
      result
    end
  end
end

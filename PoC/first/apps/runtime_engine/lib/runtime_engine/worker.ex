defmodule SetmyInfo.RuntimeEngine.Worker do
  @moduledoc """
  GenServer that represents a single loaded runtime module instance.

  Each loaded module runs in its own isolated process, registered under
  SetmyInfo.RuntimeEngine.Registry so it can be looked up by module name without
  going through the Loader.

  State tracks call count for observability/debugging.
  """

  use GenServer
  require Logger

  # ── Public API ────────────────────────────────────────────────────────────

  def start_link({module_name, impl_module}) do
    GenServer.start_link(
      __MODULE__,
      {module_name, impl_module},
      name: via(module_name)
    )
  end

  @spec execute(atom(), atom(), [term()]) :: {:ok, term()} | {:error, term()}
  def execute(module_name, function, args) do
    case Registry.lookup(SetmyInfo.RuntimeEngine.Registry, module_name) do
      [{pid, _}] ->
        # Registry removes entries asynchronously after process death, so there
        # is a brief window where a PID is returned for an already-dead process.
        # Catch the resulting :noproc exit and normalise it to {:error, :not_loaded}.
        try do
          GenServer.call(pid, {:execute, function, args})
        catch
          :exit, {:noproc, _} -> {:error, :not_loaded}
          :exit, {:normal, _} -> {:error, :not_loaded}
          :exit, {:shutdown, _} -> {:error, :not_loaded}
        end

      [] ->
        {:error, :not_loaded}
    end
  end

  # ── GenServer callbacks ───────────────────────────────────────────────────

  @impl true
  def init({module_name, impl_module}) do
    Logger.debug(
      "[SetmyInfo.RuntimeEngine.Worker] started for #{module_name} via #{inspect(impl_module)}"
    )

    {:ok, %{module_name: module_name, impl_module: impl_module, call_count: 0}}
  end

  @impl true
  def handle_call({:execute, function, args}, _from, state) do
    result = state.impl_module.execute(function, args)
    new_state = %{state | call_count: state.call_count + 1}
    {:reply, result, new_state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug(
      "[SetmyInfo.RuntimeEngine.Worker] terminating #{state.module_name}, " <>
        "calls=#{state.call_count}, reason=#{inspect(reason)}"
    )
  end

  # ── Private ───────────────────────────────────────────────────────────────

  defp via(module_name) do
    {:via, Registry, {SetmyInfo.RuntimeEngine.Registry, module_name}}
  end
end

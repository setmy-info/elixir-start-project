defmodule SetmyInfo.RuntimeEngine.Loader do
  @moduledoc """
  GenServer that manages the lifecycle of runtime modules.

  ## Responsibilities

  * **Load on demand** — starts a Worker under DynamicSupervisor when a module
    is first requested; subsequent `load/1` calls return the existing PID (idempotent).
  * **Release** — terminates the Worker and removes the ETS entry.
  * **Reload** — terminates any running Worker and starts a fresh one; useful after
    a hot code swap where Worker state also needs to be reset.
  * **Crash recovery** — on restart, reconciles its ETS table from the live
    Registry so orphaned Workers are immediately re-tracked.

  ## Reads vs writes

  ETS is `:public` so `loaded?/1`, `list_loaded/1`, and `pid_for/1` bypass the
  GenServer mailbox (O(1) read). All mutations go through `GenServer.call` so
  they are serialised and atomic.

  ## Lifecycle

      load(name)    → starts Worker, inserts {name, pid} into ETS
      reload(name)  → terminates old Worker (if any), starts fresh one
      release(name) → terminates Worker, deletes ETS entry
  """

  use GenServer
  require Logger

  @table :runtime_loaded_modules

  # ── Public API ────────────────────────────────────────────────────────────

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec load(atom()) :: {:ok, pid()} | {:error, term()}
  def load(module_name) do
    GenServer.call(__MODULE__, {:load, module_name})
  end

  @doc """
  Reload a module: terminate the running Worker (if any) and start a fresh one.

  Use after `HotCode.load_from_source/1` when Worker state also needs resetting,
  or after `ModuleRegistry.update/2` to switch implementation modules.

  If the module is not currently loaded, this behaves identically to `load/1`.
  """
  @spec reload(atom()) :: {:ok, pid()} | {:error, term()}
  def reload(module_name) do
    GenServer.call(__MODULE__, {:reload, module_name})
  end

  @spec release(atom()) :: :ok | {:error, :not_loaded}
  def release(module_name) do
    GenServer.call(__MODULE__, {:release, module_name})
  end

  @spec loaded?(atom()) :: boolean()
  def loaded?(module_name) do
    case :ets.lookup(@table, module_name) do
      [_] -> true
      [] -> false
    end
  end

  @spec pid_for(atom()) :: {:ok, pid()} | {:error, :not_loaded}
  def pid_for(module_name) do
    case :ets.lookup(@table, module_name) do
      [{^module_name, pid}] -> {:ok, pid}
      [] -> {:error, :not_loaded}
    end
  end

  @spec list_loaded() :: [atom()]
  def list_loaded do
    :ets.tab2list(@table) |> Enum.map(fn {name, _pid} -> name end)
  end

  # ── GenServer callbacks ───────────────────────────────────────────────────

  @impl true
  def init(_init_arg) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    reconcile_with_registry()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:load, module_name}, _from, state) do
    case :ets.lookup(@table, module_name) do
      [{^module_name, pid}] ->
        {:reply, {:ok, pid}, state}

      [] ->
        {:reply, start_worker(module_name), state}
    end
  end

  @impl true
  def handle_call({:reload, module_name}, _from, state) do
    terminate_worker(module_name)
    {:reply, start_worker(module_name), state}
  end

  @impl true
  def handle_call({:release, module_name}, _from, state) do
    case :ets.lookup(@table, module_name) do
      [{^module_name, _pid}] ->
        terminate_worker(module_name)
        {:reply, :ok, state}

      [] ->
        {:reply, {:error, :not_loaded}, state}
    end
  end

  # ── Private ───────────────────────────────────────────────────────────────

  defp start_worker(module_name) do
    case SetmyInfo.RuntimeEngine.ModuleRegistry.lookup(module_name) do
      {:ok, impl_module} ->
        case DynamicSupervisor.start_child(
               SetmyInfo.RuntimeEngine.DynamicSupervisor,
               {SetmyInfo.RuntimeEngine.Worker, {module_name, impl_module}}
             ) do
          {:ok, pid} ->
            :ets.insert(@table, {module_name, pid})

            Logger.info(
              "[Loader] loaded #{module_name} via #{inspect(impl_module)} (#{inspect(pid)})"
            )

            {:ok, pid}

          {:error, reason} = error ->
            Logger.warning("[Loader] failed to load #{module_name}: #{inspect(reason)}")
            error
        end

      {:error, :not_registered} = error ->
        Logger.warning("[Loader] #{module_name} is not registered in ModuleRegistry")
        error
    end
  end

  defp terminate_worker(module_name) do
    case :ets.lookup(@table, module_name) do
      [{^module_name, pid}] ->
        DynamicSupervisor.terminate_child(SetmyInfo.RuntimeEngine.DynamicSupervisor, pid)
        :ets.delete(@table, module_name)
        Logger.info("[Loader] released #{module_name} (#{inspect(pid)})")

      [] ->
        :ok
    end
  end

  # On restart, re-populate ETS from the live Registry so Workers that survived
  # a Loader crash are immediately tracked again rather than becoming orphans.
  defp reconcile_with_registry do
    entries =
      Registry.select(SetmyInfo.RuntimeEngine.Registry, [
        {{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}
      ])

    if entries != [] do
      :ets.insert(@table, entries)
      Logger.info("[Loader] reconciled #{length(entries)} surviving Worker(s) from Registry")
    end
  end
end

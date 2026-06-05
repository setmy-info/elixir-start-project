defmodule SetmyInfo.RuntimeEngine.ModuleRegistry do
  @moduledoc """
  ETS-backed registry of all known runtime module specifications.

  Separates "what modules exist" from "what modules are currently loaded".
  The Loader reads from here on demand; only modules that have been
  explicitly loaded via Loader.load/1 consume a Worker process.

  This design scales to hundreds of registered specs because unloaded
  modules have zero per-process cost — they are just ETS rows.

  Reads bypass the GenServer (direct ETS lookup, O(1)).
  Writes go through the GenServer to serialize concurrent registrations.

  Built-in modules are seeded in init/1; additional modules can be
  registered at runtime without restarting the application.
  """

  use GenServer
  require Logger

  @table :runtime_module_specs

  @builtins [
    {:math_module, SetmyInfo.RuntimeEngine.Modules.Math},
    {:string_module, SetmyInfo.RuntimeEngine.Modules.StringOps}
  ]

  # ── Public API ────────────────────────────────────────────────────────────

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc "Register a logical module name → implementation module mapping."
  @spec register(atom(), module()) :: :ok
  def register(name, impl_module) do
    GenServer.call(__MODULE__, {:register, name, impl_module})
  end

  @doc "Register many specs at once — more efficient than repeated register/2."
  @spec register_many([{atom(), module()}]) :: :ok
  def register_many(specs) when is_list(specs) do
    GenServer.call(__MODULE__, {:register_many, specs})
  end

  @doc "Remove a module spec. Does NOT unload active Workers."
  @spec unregister(atom()) :: :ok
  def unregister(name) do
    GenServer.call(__MODULE__, {:unregister, name})
  end

  @doc "Look up an implementation module by logical name. Direct ETS read."
  @spec lookup(atom()) :: {:ok, module()} | {:error, :not_registered}
  def lookup(name) do
    case :ets.lookup(@table, name) do
      [{^name, impl}] -> {:ok, impl}
      [] -> {:error, :not_registered}
    end
  end

  @doc "Update which impl module a logical name points to."
  @spec update(atom(), module()) :: :ok | {:error, :not_registered}
  def update(name, new_impl) do
    GenServer.call(__MODULE__, {:update, name, new_impl})
  end

  @spec registered?(atom()) :: boolean()
  def registered?(name), do: :ets.member(@table, name)

  @spec list_registered() :: [{atom(), module()}]
  def list_registered, do: :ets.tab2list(@table)

  @spec count() :: non_neg_integer()
  def count, do: :ets.info(@table, :size)

  # ── GenServer callbacks ───────────────────────────────────────────────────

  @impl true
  def init(_init_arg) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    :ets.insert(@table, @builtins)
    Logger.debug("[ModuleRegistry] initialised with #{length(@builtins)} built-in module(s)")
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, name, impl}, _from, state) do
    :ets.insert(@table, {name, impl})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:register_many, specs}, _from, state) do
    :ets.insert(@table, specs)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:unregister, name}, _from, state) do
    :ets.delete(@table, name)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:update, name, new_impl}, _from, state) do
    case :ets.member(@table, name) do
      true ->
        :ets.insert(@table, {name, new_impl})
        {:reply, :ok, state}

      false ->
        {:reply, {:error, :not_registered}, state}
    end
  end
end

defmodule SetmyInfo.CalculatorApp.Cache do
  @moduledoc """
  ETS-backed result cache for arithmetic operations.

  The cache is a named, public ETS table owned by this GenServer.
  Reads go directly to ETS (no GenServer mailbox) for maximum throughput.

  All public functions gracefully return a "miss" / no-op result when the
  GenServer has not been started (e.g. in test environments where
  `:server` is disabled).

  ## Example

      Cache.get(2, 3)    # => :miss   (first call)
      Cache.put(2, 3, 5)
      Cache.get(2, 3)    # => {:ok, 5}
  """

  use GenServer

  @table :calculator_cache

  @type key :: {integer(), integer()}
  @type value :: integer()

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc "Look up a cached result. Returns `{:ok, result}` on hit or `:miss`."
  @spec get(integer(), integer()) :: {:ok, value()} | :miss
  def get(a, b) do
    if :ets.whereis(@table) == :undefined do
      :miss
    else
      case :ets.lookup(@table, {a, b}) do
        [{_, result}] -> {:ok, result}
        [] -> :miss
      end
    end
  end

  @doc "Store a result and return it (pass-through)."
  @spec put(integer(), integer(), value()) :: value()
  def put(a, b, result) do
    if :ets.whereis(@table) != :undefined do
      :ets.insert(@table, {{a, b}, result})
    end

    result
  end

  @doc "Return the number of cached entries."
  @spec size() :: non_neg_integer()
  def size do
    if :ets.whereis(@table) == :undefined, do: 0, else: :ets.info(@table, :size)
  end

  @doc "Remove all cached entries."
  @spec clear() :: :ok
  def clear do
    if :ets.whereis(@table) != :undefined, do: :ets.delete_all_objects(@table)
    :ok
  end

  @impl GenServer
  def init(_) do
    :ets.new(@table, [:named_table, :public, :set, {:read_concurrency, true}])
    {:ok, %{}}
  end
end

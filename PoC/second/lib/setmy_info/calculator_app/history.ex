defmodule SetmyInfo.CalculatorApp.History do
  @moduledoc """
  GenServer that records the last 100 arithmetic operations.

  Registered in `SetmyInfo.CalculatorApp.ServiceRegistry` under the key
  `:history`, demonstrating the `{:via, Registry, ...}` pattern for
  decoupled named-process lookup.

  All public functions gracefully degrade when the process is not running
  (e.g. in test environments where `:server` is disabled):
  - `add_entry/3` uses `GenServer.cast` — never raises on a missing target.
  - `last/0` and `all/0` check the Registry before calling.

  ## Example

      History.add_entry(2, 3, 5)
      History.all()  # => [%{a: 2, b: 3, result: 5, at: ~U[...]}]
  """

  use GenServer

  @max_entries 100
  @registry SetmyInfo.CalculatorApp.ServiceRegistry

  @type entry :: %{
          a: integer(),
          b: integer(),
          result: integer(),
          at: DateTime.t()
        }

  defp via, do: {:via, Registry, {@registry, :history}}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: Keyword.get(opts, :name, via()))
  end

  @doc "Append an operation to the history (fire-and-forget, never raises)."
  @spec add_entry(integer(), integer(), integer()) :: :ok
  def add_entry(a, b, result) do
    GenServer.cast(via(), {:add, %{a: a, b: b, result: result, at: DateTime.utc_now()}})
  end

  @doc "Return the most recent entry, or `nil` if history is empty or not started."
  @spec last() :: entry() | nil
  def last do
    case pid() do
      nil -> nil
      p -> GenServer.call(p, :last)
    end
  end

  @doc "Return all entries in insertion order (oldest first). Returns `[]` if not started."
  @spec all() :: [entry()]
  def all do
    case pid() do
      nil -> []
      p -> GenServer.call(p, :all)
    end
  end

  @doc "Clear all entries (fire-and-forget)."
  @spec clear() :: :ok
  def clear do
    GenServer.cast(via(), :clear)
  end

  defp pid do
    case Process.whereis(@registry) do
      nil ->
        nil

      _ ->
        case Registry.lookup(@registry, :history) do
          [{p, _}] -> p
          [] -> nil
        end
    end
  end

  @impl GenServer
  def init(_), do: {:ok, []}

  @impl GenServer
  def handle_cast({:add, entry}, state) do
    {:noreply, Enum.take([entry | state], @max_entries)}
  end

  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  @impl GenServer
  def handle_call(:last, _from, state) do
    {:reply, List.first(state), state}
  end

  def handle_call(:all, _from, state) do
    {:reply, Enum.reverse(state), state}
  end
end

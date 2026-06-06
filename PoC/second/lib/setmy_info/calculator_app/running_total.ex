defmodule SetmyInfo.CalculatorApp.RunningTotal do
  @moduledoc """
  Agent that maintains a running sum.

  Demonstrates `Agent` as a simpler alternative to `GenServer` when shared
  mutable state requires no custom message handling — the Agent abstraction
  manages the process, mailbox, and state lifecycle automatically.

  ## Agent vs GenServer

  | Concern                  | Agent        | GenServer           |
  |--------------------------|:------------:|:-------------------:|
  | Custom message types     | ✗ — not needed | ✓ — full control  |
  | State transformation only| ✓ — ideal fit| ✓ — overkill       |
  | Built on                 | GenServer    | :gen_server         |
  | When to prefer           | Simple state | Complex behaviour   |

  Registered via `{:via, Registry, {ServiceRegistry, :running_total}}` so
  the caller decouples from the PID.  All public functions degrade gracefully
  when the process is not running.
  """

  use Agent

  alias SetmyInfo.CalculatorApp.ServiceRegistry

  @type t :: integer()

  @doc "Start the agent under the application Registry."
  @spec start_link(keyword()) :: {:ok, pid()} | {:error, term()}
  def start_link(_opts) do
    Agent.start_link(fn -> 0 end, name: via())
  end

  @doc "Return the current running total. Returns `0` if the agent is not running."
  @spec get() :: t()
  def get do
    case pid() do
      nil -> 0
      p -> Agent.get(p, & &1)
    end
  end

  @doc """
  Add `value` to the running total.

  Returns `{:ok, new_total}` on success, or `:not_running` when the agent
  has not been started.
  """
  @spec add(integer()) :: {:ok, t()} | :not_running
  def add(value) when is_integer(value) do
    case pid() do
      nil ->
        :not_running

      p ->
        new = Agent.get_and_update(p, fn total -> {total + value, total + value} end)
        {:ok, new}
    end
  end

  @doc """
  Reset the running total to `0`.

  Returns `:ok` on success, or `:not_running` when the agent has not been
  started.
  """
  @spec reset() :: :ok | :not_running
  def reset do
    case pid() do
      nil -> :not_running
      p -> Agent.update(p, fn _ -> 0 end)
    end
  end

  defp via, do: {:via, Registry, {ServiceRegistry, :running_total}}

  defp pid do
    case Process.whereis(ServiceRegistry) do
      nil ->
        nil

      _ ->
        case Registry.lookup(ServiceRegistry, :running_total) do
          [{p, _}] -> p
          [] -> nil
        end
    end
  end
end

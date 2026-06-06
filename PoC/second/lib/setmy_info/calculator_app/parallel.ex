defmodule SetmyInfo.CalculatorApp.Parallel do
  @moduledoc """
  Parallel arithmetic computation via `Task.async_stream` and
  `Task.Supervisor.async_stream_nolink`.

  ## `Task.async_stream` vs `Task.Supervisor.async_stream_nolink`

  | Variant              | Link to caller? | Caller crash kills tasks? | Tasks crash caller? |
  |----------------------|:---------------:|:------------------------:|:-------------------:|
  | `async_stream`       | yes             | yes                      | yes                 |
  | `async_stream_nolink`| no              | no                       | no                  |

  Use `async_stream` when the computation is trusted and you want failures
  to propagate.  Use the supervised variant when tasks are untrusted or
  when you need the caller to stay alive if a task crashes.
  """

  @type pair :: {integer(), integer()}
  @type batch_result :: [{integer(), integer(), integer()}]

  @doc """
  Compute `a + b` for each `{a, b}` pair concurrently using `Task.async_stream`.

  Results are returned in the same order as the input.
  """
  @spec add_many([pair()]) :: batch_result()
  def add_many(pairs) when is_list(pairs) do
    pairs
    |> Task.async_stream(fn {a, b} -> {a, b, a + b} end, max_concurrency: 10, ordered: true)
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
  Same as `add_many/1` but runs tasks under the given `Task.Supervisor`,
  so a crashing task does not crash the caller.

  In production, pass the task supervisor name registered by
  `SetmyInfo.CalculatorApp.ServiceSupervisor` at application start.
  """
  @spec supervised_add_many(Supervisor.supervisor(), [pair()]) :: batch_result()
  def supervised_add_many(supervisor, pairs) when is_list(pairs) do
    Task.Supervisor.async_stream_nolink(
      supervisor,
      pairs,
      fn {a, b} -> {a, b, a + b} end,
      max_concurrency: 10,
      ordered: true
    )
    |> Enum.map(fn {:ok, result} -> result end)
  end
end

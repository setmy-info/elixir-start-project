defmodule SetmyInfo.CalculatorApp.RunningTotalTest do
  use ExUnit.Case, async: false

  @moduletag :unit

  alias SetmyInfo.CalculatorApp.RunningTotal

  @registry SetmyInfo.CalculatorApp.ServiceRegistry

  setup do
    {:ok, reg} = Registry.start_link(keys: :unique, name: @registry)
    {:ok, pid} = RunningTotal.start_link([])

    on_exit(fn ->
      for p <- [pid, reg] do
        try do
          if Process.alive?(p), do: GenServer.stop(p)
        catch
          :exit, _ -> :ok
        end
      end
    end)

    :ok
  end

  test "get/0 returns 0 on fresh start" do
    assert RunningTotal.get() == 0
  end

  test "add/1 increases the total" do
    assert {:ok, 5} = RunningTotal.add(5)
    assert RunningTotal.get() == 5
  end

  test "add/1 is cumulative" do
    {:ok, _} = RunningTotal.add(3)
    {:ok, _} = RunningTotal.add(7)
    assert RunningTotal.get() == 10
  end

  test "add/1 works with negative values" do
    {:ok, _} = RunningTotal.add(10)
    {:ok, total} = RunningTotal.add(-3)
    assert total == 7
    assert RunningTotal.get() == 7
  end

  test "reset/0 sets total back to 0" do
    {:ok, _} = RunningTotal.add(42)
    :ok = RunningTotal.reset()
    assert RunningTotal.get() == 0
  end

  test "add/1 returns new total in the ok tuple" do
    {:ok, first} = RunningTotal.add(4)
    {:ok, second} = RunningTotal.add(6)
    assert first == 4
    assert second == 10
  end

  test "get/0 returns 0 when agent is not started" do
    [{pid, _}] = Registry.lookup(@registry, :running_total)
    GenServer.stop(pid)
    Process.sleep(10)
    assert RunningTotal.get() == 0
  end

  test "reset/0 returns :not_running when agent is not started" do
    [{pid, _}] = Registry.lookup(@registry, :running_total)
    GenServer.stop(pid)
    Process.sleep(10)
    assert RunningTotal.reset() == :not_running
  end

  test "add/1 returns :not_running when agent is not started" do
    [{pid, _}] = Registry.lookup(@registry, :running_total)
    GenServer.stop(pid)
    Process.sleep(10)
    assert RunningTotal.add(5) == :not_running
  end
end

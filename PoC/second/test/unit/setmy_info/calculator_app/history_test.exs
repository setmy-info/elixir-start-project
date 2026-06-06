defmodule SetmyInfo.CalculatorApp.HistoryTest do
  use ExUnit.Case, async: false

  alias SetmyInfo.CalculatorApp.History

  @registry SetmyInfo.CalculatorApp.ServiceRegistry

  setup do
    {:ok, reg} = Registry.start_link(keys: :unique, name: @registry)
    {:ok, pid} = History.start_link([])

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

  test "all/0 returns empty list on fresh start" do
    assert History.all() == []
  end

  test "last/0 returns nil on fresh start" do
    assert History.last() == nil
  end

  test "add_entry/3 appends to history" do
    History.add_entry(2, 3, 5)
    Process.sleep(10)
    entries = History.all()
    assert length(entries) == 1
    assert hd(entries).a == 2
    assert hd(entries).b == 3
    assert hd(entries).result == 5
  end

  test "all/0 returns entries in insertion order (oldest first)" do
    History.add_entry(1, 1, 2)
    History.add_entry(2, 2, 4)
    History.add_entry(3, 3, 6)
    Process.sleep(20)
    results = Enum.map(History.all(), & &1.result)
    assert results == [2, 4, 6]
  end

  test "last/0 returns the most recent entry" do
    History.add_entry(1, 1, 2)
    History.add_entry(9, 9, 18)
    Process.sleep(20)
    assert History.last().result == 18
  end

  test "clear/0 removes all entries" do
    History.add_entry(1, 2, 3)
    Process.sleep(10)
    History.clear()
    Process.sleep(10)
    assert History.all() == []
  end

  test "entries include a DateTime timestamp" do
    History.add_entry(1, 2, 3)
    Process.sleep(10)
    entry = History.last()
    assert %DateTime{} = entry.at
  end

  test "returns empty list when history is not started" do
    # Stop history and registry so they're gone
    # (using Process.whereis to find the actual pids)
    [{pid, _}] = Registry.lookup(@registry, :history)
    GenServer.stop(pid)
    Process.sleep(10)
    assert History.all() == []
    assert History.last() == nil
  end
end

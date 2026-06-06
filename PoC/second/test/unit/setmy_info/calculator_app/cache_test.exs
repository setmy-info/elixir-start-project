defmodule SetmyInfo.CalculatorApp.CacheTest do
  use ExUnit.Case, async: false

  alias SetmyInfo.CalculatorApp.Cache

  setup do
    {:ok, pid} = Cache.start_link([])
    on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
    :ok
  end

  test "get/2 returns :miss for an unknown key" do
    assert Cache.get(1, 2) == :miss
  end

  test "put/3 stores a result and returns it" do
    assert Cache.put(1, 2, 3) == 3
  end

  test "get/2 returns {:ok, result} after put/3" do
    Cache.put(2, 3, 5)
    assert Cache.get(2, 3) == {:ok, 5}
  end

  test "different keys do not collide" do
    Cache.put(1, 2, 3)
    Cache.put(2, 1, 99)
    assert Cache.get(1, 2) == {:ok, 3}
    assert Cache.get(2, 1) == {:ok, 99}
  end

  test "size/0 reflects the number of stored entries" do
    assert Cache.size() == 0
    Cache.put(1, 1, 2)
    assert Cache.size() == 1
    Cache.put(2, 2, 4)
    assert Cache.size() == 2
  end

  test "clear/0 removes all entries" do
    Cache.put(1, 2, 3)
    Cache.put(4, 5, 9)
    Cache.clear()
    assert Cache.size() == 0
    assert Cache.get(1, 2) == :miss
  end

  test "put/3 is a no-op and still returns the value when ETS table is gone" do
    # Delete the table directly to simulate a not-started cache
    :ets.delete(:calculator_cache)
    assert Cache.put(1, 2, 42) == 42
    assert Cache.get(1, 2) == :miss
    assert Cache.size() == 0
  end
end

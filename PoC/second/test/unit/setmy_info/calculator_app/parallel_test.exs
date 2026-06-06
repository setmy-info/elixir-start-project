defmodule SetmyInfo.CalculatorApp.ParallelTest do
  use ExUnit.Case, async: true

  alias SetmyInfo.CalculatorApp.Parallel

  describe "add_many/1" do
    test "returns results in the same order as input" do
      pairs = [{1, 2}, {3, 4}, {5, 6}]
      assert Parallel.add_many(pairs) == [{1, 2, 3}, {3, 4, 7}, {5, 6, 11}]
    end

    test "handles an empty list" do
      assert Parallel.add_many([]) == []
    end

    test "handles a single pair" do
      assert Parallel.add_many([{10, 20}]) == [{10, 20, 30}]
    end

    test "handles negative numbers" do
      assert Parallel.add_many([{-5, -3}]) == [{-5, -3, -8}]
    end

    test "handles many pairs concurrently" do
      pairs = for n <- 1..50, do: {n, n}
      results = Parallel.add_many(pairs)
      assert length(results) == 50

      for {{a, b, r}, n} <- Enum.zip(results, 1..50) do
        assert a == n
        assert b == n
        assert r == n * 2
      end
    end
  end

  describe "supervised_add_many/2" do
    setup do
      {:ok, sup} = Task.Supervisor.start_link()
      %{sup: sup}
    end

    test "returns the same results as add_many/1", %{sup: sup} do
      pairs = [{1, 2}, {3, 4}]
      assert Parallel.supervised_add_many(sup, pairs) == Parallel.add_many(pairs)
    end

    test "handles empty list under supervisor", %{sup: sup} do
      assert Parallel.supervised_add_many(sup, []) == []
    end
  end
end

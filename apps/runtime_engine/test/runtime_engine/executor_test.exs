defmodule SetmyInfo.RuntimeEngine.ExecutorTest do
  use ExUnit.Case

  alias SetmyInfo.RuntimeEngine.{Executor, Loader}

  setup do
    on_exit(fn ->
      Loader.list_loaded() |> Enum.each(&Loader.release/1)
    end)

    :ok
  end

  describe "run/3" do
    test "loads, executes, and leaves module loaded" do
      assert {:ok, 5} = Executor.run(:math_module, :add, [2, 3])
      assert Loader.loaded?(:math_module)
    end

    test "multiple calls reuse the same worker" do
      Executor.run(:math_module, :add, [1, 1])
      Executor.run(:math_module, :add, [2, 2])
      # still only one instance loaded
      assert [:math_module] == Loader.list_loaded()
    end
  end

  describe "run_and_release/3" do
    test "executes and releases the module" do
      assert {:ok, 5} = Executor.run_and_release(:math_module, :add, [2, 3])
      refute Loader.loaded?(:math_module)
    end

    test "multiply via run_and_release" do
      assert {:ok, 12} = Executor.run_and_release(:math_module, :multiply, [3, 4])
    end

    test "unknown function returns error" do
      assert {:error, {:undefined_function, :unknown}} =
               Executor.run_and_release(:math_module, :unknown, [])
    end
  end
end

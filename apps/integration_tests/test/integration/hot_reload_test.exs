defmodule SetmyInfo.Integration.HotReloadTest do
  @moduledoc """
  Demonstrates hot code reload: the Worker process keeps running while its
  underlying module implementation is swapped out live.

  v1 → add(3, 7) returns 10
  v2 → add(3, 7) returns 100   (same Worker PID, no restart)
  """

  use ExUnit.Case

  alias SetmyInfo.RuntimeEngine.{HotCode, Loader, ModuleRegistry, Worker}

  @name :hot_adder
  @module SetmyInfo.Support.HotAdder

  @v1 """
  defmodule SetmyInfo.Support.HotAdder do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :hot_adder
    def execute(:add, [a, b]), do: {:ok, a + b}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
  """

  @v2 """
  defmodule SetmyInfo.Support.HotAdder do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :hot_adder
    def execute(:add, [a, b]), do: {:ok, (a + b) * 10}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
  """

  setup do
    {:ok, _} = HotCode.load_from_source(@v1)
    ModuleRegistry.register(@name, @module)

    on_exit(fn ->
      if Loader.loaded?(@name), do: Loader.release(@name)
      ModuleRegistry.unregister(@name)
      HotCode.purge(@module)
      HotCode.delete(@module)
    end)

    :ok
  end

  test "same Worker PID uses new code after hot swap" do
    {:ok, pid} = Loader.load(@name)

    # v1: plain addition
    assert {:ok, 10} = Worker.execute(@name, :add, [3, 7])

    # Swap to v2 — no Worker restart
    {:ok, _} = HotCode.load_from_source(@v2)

    assert Process.alive?(pid), "Worker must still be running after hot swap"
    assert {:ok, 100} = Worker.execute(@name, :add, [3, 7])
  end
end

defmodule SetmyInfo.RuntimeEngine.LoaderTest do
  use ExUnit.Case

  alias SetmyInfo.RuntimeEngine.Loader

  setup do
    # Each test gets a fresh ETS state via the running Loader GenServer.
    # Release any module that might have been left loaded.
    on_exit(fn ->
      Loader.list_loaded() |> Enum.each(&Loader.release/1)
    end)

    :ok
  end

  test "load/1 starts a worker and returns {:ok, pid}" do
    assert {:ok, pid} = Loader.load(:math_module)
    assert is_pid(pid)
    assert Process.alive?(pid)
  end

  test "load/1 is idempotent — returns the same pid on second call" do
    {:ok, pid1} = Loader.load(:math_module)
    {:ok, pid2} = Loader.load(:math_module)
    assert pid1 == pid2
  end

  test "loaded?/1 returns true after load, false after release" do
    refute Loader.loaded?(:math_module)
    Loader.load(:math_module)
    assert Loader.loaded?(:math_module)
    Loader.release(:math_module)
    refute Loader.loaded?(:math_module)
  end

  test "release/1 terminates the worker process" do
    {:ok, pid} = Loader.load(:math_module)
    assert :ok = Loader.release(:math_module)
    # Allow the process to exit
    refute Process.alive?(pid)
  end

  test "release/1 returns error when module is not loaded" do
    assert {:error, :not_loaded} = Loader.release(:math_module)
  end

  test "list_loaded/0 reflects current state" do
    assert [] == Loader.list_loaded()
    Loader.load(:math_module)
    assert :math_module in Loader.list_loaded()
    Loader.release(:math_module)
    assert [] == Loader.list_loaded()
  end
end

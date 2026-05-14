defmodule SetmyInfo.Integration.DynamicModuleTest do
  @moduledoc """
  Integration test: dynamically compile an Elixir adder module, load it into
  the RuntimeEngine, use it, then release it.

  Demonstrates the full lifecycle with a module that does NOT exist at compile
  time — the source is compiled at runtime via HotCode.load_from_source/1.
  """

  use ExUnit.Case

  alias SetmyInfo.RuntimeEngine.{HotCode, Loader, ModuleRegistry, Worker}

  @logical_name :dynamic_adder
  @impl_module SetmyInfo.RuntimeEngine.Modules.DynamicAdder

  # Elixir source compiled at runtime — not available at compile time.
  @source """
  defmodule SetmyInfo.RuntimeEngine.Modules.DynamicAdder do
    @behaviour SetmyInfo.RuntimeEngine.Module

    def name, do: :dynamic_adder

    def execute(:add, [a, b]) when is_number(a) and is_number(b), do: {:ok, a + b}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
  """

  setup do
    on_exit(fn ->
      if Loader.loaded?(@logical_name), do: Loader.release(@logical_name)
      if ModuleRegistry.registered?(@logical_name), do: ModuleRegistry.unregister(@logical_name)
      HotCode.purge(@impl_module)
      HotCode.delete(@impl_module)
    end)

    :ok
  end

  test "load → add(4, 6) → release: full lifecycle with a dynamically compiled module" do
    # 1. Compile the Elixir source and load the BEAM code into the VM.
    assert {:ok, _modules} = HotCode.load_from_source(@source)
    assert Code.ensure_loaded?(@impl_module), "module must be callable after load_from_source"

    # 2. Register the logical name so the Loader can resolve it.
    :ok = ModuleRegistry.register(@logical_name, @impl_module)
    assert ModuleRegistry.registered?(@logical_name)

    # 3. Load: start a supervised Worker process.
    assert {:ok, pid} = Loader.load(@logical_name)
    assert is_pid(pid)
    assert Process.alive?(pid)
    assert Loader.loaded?(@logical_name)

    # 4. Execute: call the add function through the Worker.
    assert {:ok, 10} = Worker.execute(@logical_name, :add, [4, 6])
    assert {:ok, 0} = Worker.execute(@logical_name, :add, [0, 0])
    assert {:ok, -3} = Worker.execute(@logical_name, :add, [2, -5])

    # 5. Release: terminate the Worker and free the tracked slot.
    assert :ok = Loader.release(@logical_name)
    refute Process.alive?(pid), "Worker process must be gone after release"
    refute Loader.loaded?(@logical_name), "module must not be tracked after release"
  end

  test "Worker is unreachable after release" do
    {:ok, _} = HotCode.load_from_source(@source)
    ModuleRegistry.register(@logical_name, @impl_module)
    Loader.load(@logical_name)

    Loader.release(@logical_name)

    assert {:error, :not_loaded} = Worker.execute(@logical_name, :add, [1, 2])
  end

  test "module can be re-loaded after release" do
    {:ok, _} = HotCode.load_from_source(@source)
    ModuleRegistry.register(@logical_name, @impl_module)

    {:ok, pid1} = Loader.load(@logical_name)
    Loader.release(@logical_name)

    {:ok, pid2} = Loader.load(@logical_name)
    assert pid1 != pid2, "re-load must start a new Worker process"
    assert {:ok, 7} = Worker.execute(@logical_name, :add, [3, 4])
  end
end

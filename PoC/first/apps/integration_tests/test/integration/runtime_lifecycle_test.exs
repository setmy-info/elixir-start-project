defmodule SetmyInfo.Integration.RuntimeLifecycleTest do
  @moduledoc """
  Integration test: load → use → release lifecycle.

  Demonstrates the core use-case of the RuntimeEngine:
    1. Load a named module (starts a supervised Worker process).
    2. Execute a function on it (add two numbers).
    3. Release the module (terminates the Worker, frees resources).

  All assertions run against the live OTP supervision tree — no mocks.
  """

  use ExUnit.Case

  alias SetmyInfo.RuntimeEngine.{Executor, Loader, Worker}

  setup do
    # Ensure no module is left loaded between tests.
    on_exit(fn -> Loader.list_loaded() |> Enum.each(&Loader.release/1) end)
    :ok
  end

  # ── Step-by-step lifecycle ────────────────────────────────────────────────

  test "step 1 – load: starts a supervised Worker process" do
    {:ok, pid} = Loader.load(:math_module)

    assert is_pid(pid), "Loader must return a PID"
    assert Process.alive?(pid), "Worker process must be alive after load"
    assert Loader.loaded?(:math_module)
  end

  test "step 2 – execute: add(2, 3) returns 5" do
    Loader.load(:math_module)

    assert {:ok, 5} = Worker.execute(:math_module, :add, [2, 3])
  end

  test "step 3 – release: terminates the Worker and clears tracking" do
    {:ok, pid} = Loader.load(:math_module)

    :ok = Loader.release(:math_module)

    refute Process.alive?(pid), "Worker process must be gone after release"
    refute Loader.loaded?(:math_module), "Module must not be tracked after release"
  end

  # ── Full lifecycle in one test ────────────────────────────────────────────

  test "full lifecycle: load → add(2, 3) → release" do
    # 1. Load
    {:ok, _pid} = Loader.load(:math_module)

    # 2. Use
    assert {:ok, 5} = Worker.execute(:math_module, :add, [2, 3])

    # 3. Release
    assert :ok = Loader.release(:math_module)
    refute Loader.loaded?(:math_module)
  end

  test "Executor.run_and_release/3: load + execute + release in a single call" do
    refute Loader.loaded?(:math_module)

    assert {:ok, 5} = Executor.run_and_release(:math_module, :add, [2, 3])

    refute Loader.loaded?(:math_module)
  end

  # ── Post-release behaviour ────────────────────────────────────────────────

  test "executing after release returns :not_loaded" do
    Loader.load(:math_module)
    Loader.release(:math_module)

    assert {:error, :not_loaded} = Worker.execute(:math_module, :add, [1, 2])
  end

  test "the module can be reloaded after release" do
    Loader.load(:math_module)
    Loader.release(:math_module)

    {:ok, _pid} = Loader.load(:math_module)
    assert {:ok, 5} = Worker.execute(:math_module, :add, [2, 3])
  end
end

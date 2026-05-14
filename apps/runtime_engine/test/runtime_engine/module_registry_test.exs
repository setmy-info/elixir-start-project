defmodule SetmyInfo.RuntimeEngine.ModuleRegistryTest do
  use ExUnit.Case, async: false

  alias SetmyInfo.RuntimeEngine.ModuleRegistry

  @test_name :test_registry_module

  setup do
    on_exit(fn -> ModuleRegistry.unregister(@test_name) end)
    :ok
  end

  describe "built-in modules" do
    test "math_module is pre-registered" do
      assert {:ok, SetmyInfo.RuntimeEngine.Modules.Math} = ModuleRegistry.lookup(:math_module)
    end

    test "string_module is pre-registered" do
      assert {:ok, SetmyInfo.RuntimeEngine.Modules.StringOps} =
               ModuleRegistry.lookup(:string_module)
    end
  end

  describe "register/2 and lookup/1" do
    test "registers a new module spec" do
      :ok = ModuleRegistry.register(@test_name, SetmyInfo.RuntimeEngine.Modules.Math)
      assert {:ok, SetmyInfo.RuntimeEngine.Modules.Math} = ModuleRegistry.lookup(@test_name)
    end

    test "lookup returns :not_registered for unknown name" do
      assert {:error, :not_registered} = ModuleRegistry.lookup(:definitely_not_there)
    end

    test "registered?/1 returns true after register, false otherwise" do
      refute ModuleRegistry.registered?(@test_name)
      ModuleRegistry.register(@test_name, SetmyInfo.RuntimeEngine.Modules.Math)
      assert ModuleRegistry.registered?(@test_name)
    end
  end

  describe "register_many/1" do
    test "bulk registers multiple specs" do
      specs = for i <- 1..10, do: {:"bulk_#{i}", SetmyInfo.RuntimeEngine.Modules.Math}
      :ok = ModuleRegistry.register_many(specs)

      for {name, _impl} <- specs do
        assert {:ok, SetmyInfo.RuntimeEngine.Modules.Math} = ModuleRegistry.lookup(name)
        ModuleRegistry.unregister(name)
      end
    end
  end

  describe "update/2" do
    test "changes the impl module for an existing spec" do
      ModuleRegistry.register(@test_name, SetmyInfo.RuntimeEngine.Modules.Math)
      :ok = ModuleRegistry.update(@test_name, SetmyInfo.RuntimeEngine.Modules.StringOps)
      assert {:ok, SetmyInfo.RuntimeEngine.Modules.StringOps} = ModuleRegistry.lookup(@test_name)
    end

    test "returns error for unknown name" do
      assert {:error, :not_registered} =
               ModuleRegistry.update(:no_such_module, SetmyInfo.RuntimeEngine.Modules.Math)
    end
  end

  describe "unregister/1" do
    test "removes the spec" do
      ModuleRegistry.register(@test_name, SetmyInfo.RuntimeEngine.Modules.Math)
      :ok = ModuleRegistry.unregister(@test_name)
      assert {:error, :not_registered} = ModuleRegistry.lookup(@test_name)
    end
  end

  describe "count/0 and list_registered/0" do
    test "count includes built-ins" do
      assert ModuleRegistry.count() >= 2
    end

    test "list_registered returns all specs" do
      names = ModuleRegistry.list_registered() |> Enum.map(fn {n, _} -> n end)
      assert :math_module in names
      assert :string_module in names
    end

    test "count increases after register" do
      before = ModuleRegistry.count()
      ModuleRegistry.register(@test_name, SetmyInfo.RuntimeEngine.Modules.Math)
      assert ModuleRegistry.count() == before + 1
    end
  end

  test "registry handles 500 registered specs without bloat" do
    specs = for i <- 1..500, do: {:"perf_module_#{i}", SetmyInfo.RuntimeEngine.Modules.Math}
    :ok = ModuleRegistry.register_many(specs)

    assert ModuleRegistry.count() >= 500

    # Lookup is O(1) via ETS regardless of registry size
    assert {:ok, SetmyInfo.RuntimeEngine.Modules.Math} = ModuleRegistry.lookup(:perf_module_250)

    # Clean up
    for {name, _} <- specs, do: ModuleRegistry.unregister(name)
  end
end

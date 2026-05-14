defmodule SetmyInfo.RuntimeEngine.HotCodeTest do
  use ExUnit.Case, async: false

  alias SetmyInfo.RuntimeEngine.HotCode

  # Module name used across hot reload tests — global atom, so tests are non-async.
  @hot_module SetmyInfo.RuntimeEngine.Modules.HotCodeTest

  @source_v1 """
  defmodule SetmyInfo.RuntimeEngine.Modules.HotCodeTest do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :hot_code_test
    def execute(:compute, [x]), do: {:ok, x * 2}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
  """

  @source_v2 """
  defmodule SetmyInfo.RuntimeEngine.Modules.HotCodeTest do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :hot_code_test
    def execute(:compute, [x]), do: {:ok, x * 3}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
  """

  setup do
    on_exit(fn ->
      :code.delete(@hot_module)
      :code.purge(@hot_module)
    end)

    :ok
  end

  describe "load_from_source/1" do
    test "compiles and loads a module into the VM" do
      assert {:ok, [{@hot_module, _beam}]} = HotCode.load_from_source(@source_v1)
      # Module is now callable
      assert {:ok, 10} = @hot_module.execute(:compute, [5])
    end

    test "reloads module with new behaviour (v1 → v2)" do
      {:ok, _} = HotCode.load_from_source(@source_v1)
      assert {:ok, 10} = @hot_module.execute(:compute, [5])

      {:ok, _} = HotCode.load_from_source(@source_v2)
      assert {:ok, 15} = @hot_module.execute(:compute, [5])
    end

    test "returns error for invalid Elixir source" do
      assert {:error, _} = HotCode.load_from_source("this is not valid {{ elixir")
    end
  end

  describe "load_from_beam/2" do
    test "loads from BEAM binary produced by compile_string" do
      [{module_name, beam_binary}] = Code.compile_string(@source_v1)
      # Purge first so we can re-load cleanly
      :code.delete(module_name)
      :code.purge(module_name)

      assert :ok = HotCode.load_from_beam(module_name, beam_binary)
      assert {:ok, 10} = @hot_module.execute(:compute, [5])
    end
  end

  describe "purge/1" do
    test "soft purge returns boolean" do
      HotCode.load_from_source(@source_v1)
      # Reload to create an old version
      HotCode.load_from_source(@source_v2)
      result = HotCode.purge(@hot_module)
      assert is_boolean(result)
    end
  end

  describe "module_md5/1" do
    test "returns hex string for loaded module" do
      HotCode.load_from_source(@source_v1)
      md5_v1 = HotCode.module_md5(@hot_module)
      assert is_binary(md5_v1)
      assert byte_size(md5_v1) == 32

      HotCode.load_from_source(@source_v2)
      md5_v2 = HotCode.module_md5(@hot_module)
      # MD5 changes after hot reload
      assert md5_v1 != md5_v2
    end

    test "returns nil for unknown module" do
      assert nil == HotCode.module_md5(:definitely_not_loaded_xyz)
    end
  end
end

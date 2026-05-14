defmodule SetmyInfo.RuntimeEngine.HotCodeTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

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
      # Full removal sequence:
      #   1. purge  — drop the "old" version if one exists (e.g. after hot reload)
      #   2. delete — mark "current" as "old"
      #   3. purge  — drop that (now old) version
      :code.purge(@hot_module)
      :code.delete(@hot_module)
      :code.purge(@hot_module)
    end)

    :ok
  end

  describe "load_from_source/1" do
    test "compiles and loads a module into the VM" do
      assert {:ok, [{@hot_module, _beam}]} = HotCode.load_from_source(@source_v1)
      assert {:ok, 10} = apply(@hot_module, :execute, [:compute, [5]])
    end

    test "reloads module with new behaviour (v1 → v2)" do
      {:ok, _} = HotCode.load_from_source(@source_v1)
      assert {:ok, 10} = apply(@hot_module, :execute, [:compute, [5]])

      {:ok, _} = HotCode.load_from_source(@source_v2)
      assert {:ok, 15} = apply(@hot_module, :execute, [:compute, [5]])
    end

    test "returns error for invalid Elixir source" do
      # capture_log swallows the expected Logger.warning from HotCode
      capture_log(fn ->
        assert {:error, _} = HotCode.load_from_source("this is not valid {{ elixir")
      end)
    end
  end

  describe "load_from_beam/2" do
    test "loads from BEAM binary produced by compile_string" do
      # Compile without triggering a redefine warning (module may already exist
      # in the VM from a previous test run in the same node).
      Code.put_compiler_option(:ignore_module_conflict, true)
      [{module_name, beam_binary}] = Code.compile_string(@source_v1)
      Code.put_compiler_option(:ignore_module_conflict, false)

      # Remove the just-compiled version so load_from_beam proves it reloads it.
      :code.purge(module_name)
      :code.delete(module_name)
      :code.purge(module_name)

      assert :ok = HotCode.load_from_beam(module_name, beam_binary)
      assert {:ok, 10} = apply(@hot_module, :execute, [:compute, [5]])
    end
  end

  describe "purge/1" do
    test "soft purge returns boolean" do
      HotCode.load_from_source(@source_v1)
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
      assert md5_v1 != md5_v2
    end

    test "returns nil for unknown module" do
      assert nil == HotCode.module_md5(:definitely_not_loaded_xyz)
    end
  end
end

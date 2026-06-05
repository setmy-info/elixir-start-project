defmodule SetmyInfo.Integration.AdderFileTest do
  @moduledoc "Load SetmyInfo.Support.Adder from its .ex file, call add, then unload."

  use ExUnit.Case

  @adder_file Path.expand("../../fixtures/adder.ex", __DIR__)

  setup do
    on_exit(fn ->
      :code.purge(SetmyInfo.Support.Adder)
      :code.delete(SetmyInfo.Support.Adder)
    end)

    :ok
  end

  test "load adder.ex by file name, add(3, 7) returns 10, then unload" do
    Code.compile_file(@adder_file)

    assert 10 == apply(SetmyInfo.Support.Adder, :add, [3, 7])

    :code.purge(SetmyInfo.Support.Adder)
    :code.delete(SetmyInfo.Support.Adder)
  end
end

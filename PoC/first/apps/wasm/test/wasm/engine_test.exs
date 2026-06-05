defmodule SetmyInfo.Wasm.EngineTest do
  use ExUnit.Case, async: true

  alias SetmyInfo.Wasm.Engine

  test "load/1 returns :not_implemented (stub)" do
    assert {:error, :not_implemented} = Engine.load(<<>>)
  end

  test "execute/3 returns :not_implemented (stub)" do
    assert {:error, :not_implemented} = Engine.execute(make_ref(), "add", [1, 2])
  end

  test "release/1 always succeeds (no-op)" do
    assert :ok = Engine.release(make_ref())
  end
end

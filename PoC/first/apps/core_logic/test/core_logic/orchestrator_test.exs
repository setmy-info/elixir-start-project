defmodule SetmyInfo.CoreLogic.OrchestratorTest do
  use ExUnit.Case, async: true

  alias SetmyInfo.CoreLogic.Orchestrator

  describe "add/2" do
    test "adds two positive integers" do
      assert Orchestrator.add(2, 3) == 5
    end

    test "adds negative numbers" do
      assert Orchestrator.add(-1, -2) == -3
    end

    test "adds floats" do
      assert Orchestrator.add(1.5, 2.5) == 4.0
    end
  end

  describe "multiply/2" do
    test "multiplies two numbers" do
      assert Orchestrator.multiply(3, 4) == 12
    end

    test "multiply by zero" do
      assert Orchestrator.multiply(100, 0) == 0
    end
  end

  describe "subtract/2" do
    test "subtracts two numbers" do
      assert Orchestrator.subtract(10, 3) == 7
    end
  end
end

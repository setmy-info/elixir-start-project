defmodule SetmyInfo.CalculatorApp.OperationTest do
  use ExUnit.Case, async: true

  alias SetmyInfo.CalculatorApp.Operation
  alias SetmyInfo.CalculatorApp.Operations.{Add, Divide, Multiply, Subtract}

  describe "Operation.find/1" do
    test "returns the Add module for 'add'" do
      assert Operation.find("add") == Add
    end

    test "returns the Subtract module for 'subtract'" do
      assert Operation.find("subtract") == Subtract
    end

    test "returns the Multiply module for 'multiply'" do
      assert Operation.find("multiply") == Multiply
    end

    test "returns the Divide module for 'divide'" do
      assert Operation.find("divide") == Divide
    end

    test "returns nil for an unknown operation" do
      assert Operation.find("modulo") == nil
    end
  end

  describe "Operation.all/0" do
    test "returns a map of all four operations" do
      ops = Operation.all()
      assert map_size(ops) == 4
      assert Map.keys(ops) |> Enum.sort() == ["add", "divide", "multiply", "subtract"]
    end
  end

  describe "Add.execute/2" do
    test "returns {:ok, sum}" do
      assert Add.execute(2, 3) == {:ok, 5}
    end

    test "name/0 returns 'add'" do
      assert Add.name() == "add"
    end
  end

  describe "Subtract.execute/2" do
    test "returns {:ok, difference}" do
      assert Subtract.execute(10, 3) == {:ok, 7}
    end

    test "supports negative results" do
      assert Subtract.execute(3, 10) == {:ok, -7}
    end
  end

  describe "Multiply.execute/2" do
    test "returns {:ok, product}" do
      assert Multiply.execute(4, 5) == {:ok, 20}
    end

    test "multiply by zero returns zero" do
      assert Multiply.execute(100, 0) == {:ok, 0}
    end
  end

  describe "Divide.execute/2" do
    test "returns {:ok, quotient} for integer division" do
      assert Divide.execute(10, 3) == {:ok, 3}
    end

    test "returns {:error, ...} when divisor is zero" do
      assert {:error, reason} = Divide.execute(5, 0)
      assert String.contains?(reason, "zero")
    end
  end

  describe "@behaviour enforcement" do
    test "all operation modules implement name/0 and execute/2" do
      for mod <- [Add, Divide, Multiply, Subtract] do
        assert is_binary(mod.name())
        assert {:ok, _} = mod.execute(6, 2)
      end
    end
  end
end

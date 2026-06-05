defmodule Math.MathServiceTest do
  use ExUnit.Case

  alias Math.MathService

  doctest Math.MathService

  test "adds two integers correctly" do
    assert MathService.add(2, 3) == 5
  end

  test "works with zero" do
    assert MathService.add(0, 10) == 10
  end

  test "adds negative numbers" do
    assert MathService.add(-4, -6) == -10
  end

  test "adds two zeros" do
    assert MathService.add(0, 0) == 0
  end

  test "adds larger integers" do
    assert MathService.add(1_000_000, 2_500_000) == 3_500_000
  end
end

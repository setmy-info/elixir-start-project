defmodule SetmyInfo.Math.MathServicePropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias SetmyInfo.Math.MathService

  @moduletag :property

  property "add/2 is commutative: add(a, b) == add(b, a)" do
    check all(a <- integer(), b <- integer()) do
      assert MathService.add(a, b) == MathService.add(b, a)
    end
  end

  property "add/2 has zero as the identity element" do
    check all(a <- integer()) do
      assert MathService.add(a, 0) == a
      assert MathService.add(0, a) == a
    end
  end

  property "add/2 is associative: add(add(a,b),c) == add(a,add(b,c))" do
    check all(
            a <- integer(-1_000..1_000),
            b <- integer(-1_000..1_000),
            c <- integer(-1_000..1_000)
          ) do
      assert MathService.add(MathService.add(a, b), c) ==
               MathService.add(a, MathService.add(b, c))
    end
  end

  property "add/2 of two positive integers is positive" do
    check all(a <- positive_integer(), b <- positive_integer()) do
      assert MathService.add(a, b) > 0
    end
  end

  property "add/2 of two negative integers is negative" do
    check all(a <- positive_integer(), b <- positive_integer()) do
      assert MathService.add(-a, -b) < 0
    end
  end
end

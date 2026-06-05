defmodule SetmyInfo.Lessons.OperatorsTest do
  @moduledoc "Lesson: Elixir operators — arithmetic, comparison, logical, string, list, pipe."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.Operators

  describe "Arithmetic operators" do
    test "+, -, *, /, div, rem, power" do
      IO.puts("\n=== ARITHMETIC OPERATORS ===")
      IO.puts("3 + 2        => #{Operators.add(3, 2)}")
      IO.puts("10 - 3       => #{Operators.subtract(10, 3)}")
      IO.puts("4 * 5        => #{Operators.multiply(4, 5)}")
      IO.puts("7 / 2        => #{Operators.divide(7, 2)}")
      IO.puts("div(7, 2)    => #{Operators.floor_div(7, 2)}")
      IO.puts("rem(7, 2)    => #{Operators.remainder(7, 2)}")
      IO.puts(":math.pow(2,10) => #{Operators.power(2, 10)}")

      assert Operators.add(3, 2) == 5
      assert Operators.subtract(10, 3) == 7
      assert Operators.multiply(4, 5) == 20
      assert Operators.divide(7, 2) == 3.5
      assert Operators.floor_div(7, 2) == 3
      assert Operators.remainder(7, 2) == 1
      assert Operators.power(2, 10) == 1024.0
    end
  end

  describe "Comparison operators" do
    test "== structural equality vs === strict equality" do
      IO.puts("\n=== COMPARISON OPERATORS ===")
      IO.puts("1 == 1.0      => #{Operators.equal?(1, 1.0)}")
      IO.puts("1 === 1.0     => #{Operators.strict_equal?(1, 1.0)}")
      IO.puts("1 != 2        => #{Operators.not_equal?(1, 2)}")
      IO.puts("1 < 2         => #{Operators.less_than?(1, 2)}")
      IO.puts("5 > 3         => #{Operators.greater_than?(5, 3)}")
      IO.puts("3 <= 3        => #{Operators.lte?(3, 3)}")
      IO.puts("4 >= 5        => #{Operators.gte?(4, 5)}")

      assert Operators.equal?(1, 1) == true
      assert Operators.equal?(1, 1.0) == true
      assert Operators.strict_equal?(1, 1.0) == false
      assert Operators.strict_equal?(1, 1) == true
      assert Operators.less_than?(1, 2) == true
      assert Operators.gte?(5, 5) == true
    end
  end

  describe "Logical operators — strict (boolean only)" do
    test "and, or, not require boolean operands" do
      IO.puts("\n=== LOGICAL OPERATORS (strict) ===")
      IO.puts("true and true    => #{Operators.logical_and(true, true)}")
      IO.puts("true and false   => #{Operators.logical_and(true, false)}")
      IO.puts("false or true    => #{Operators.logical_or(false, true)}")
      IO.puts("not true         => #{Operators.logical_not(true)}")

      assert Operators.logical_and(true, true) == true
      assert Operators.logical_and(true, false) == false
      assert Operators.logical_or(false, true) == true
      assert Operators.logical_not(true) == false
    end
  end

  describe "Logical operators — truthy (any value)" do
    test "&&, ||, ! work with any truthy/falsy value" do
      IO.puts("\n=== LOGICAL OPERATORS (truthy) ===")
      IO.puts("nil && :ok      => #{inspect(Operators.truthy_and(nil, :ok))}")
      IO.puts(":ok && :yes     => #{inspect(Operators.truthy_and(:ok, :yes))}")
      IO.puts("nil || :fallback=> #{inspect(Operators.truthy_or(nil, :fallback))}")
      IO.puts(":ok || :unused  => #{inspect(Operators.truthy_or(:ok, :unused))}")
      IO.puts("!nil            => #{Operators.truthy_not(nil)}")
      IO.puts("!false          => #{Operators.truthy_not(false)}")
      IO.puts("!:ok            => #{Operators.truthy_not(:ok)}")

      assert Operators.truthy_and(nil, :ok) == nil
      assert Operators.truthy_and(:ok, :yes) == :yes
      assert Operators.truthy_or(nil, :fallback) == :fallback
      assert Operators.truthy_or(:ok, :unused) == :ok
      assert Operators.truthy_not(nil) == true
      assert Operators.truthy_not(:ok) == false
    end
  end

  describe "String and list operators" do
    test "<> concatenates strings, ++ and -- operate on lists" do
      IO.puts("\n=== STRING & LIST OPERATORS ===")
      IO.puts("\"foo\" <> \"bar\"       => #{Operators.concat("foo", "bar")}")
      IO.puts("[1,2] ++ [3,4]       => #{inspect(Operators.list_concat([1, 2], [3, 4]))}")
      IO.puts("[1,2,2,3] -- [2]     => #{inspect(Operators.list_diff([1, 2, 2, 3], [2]))}")

      assert Operators.concat("foo", "bar") == "foobar"
      assert Operators.list_concat([1, 2], [3, 4]) == [1, 2, 3, 4]
      assert Operators.list_diff([1, 2, 2, 3], [2]) == [1, 2, 3]
    end
  end

  describe "Pattern match operator" do
    test "= is structural matching, not assignment" do
      IO.puts("\n=== PATTERN MATCH = ===")
      result = Operators.match_tuple()
      IO.puts("matched {:ok, 42} => #{inspect(result)}")

      {status, value} = result
      IO.puts("status: #{status}, value: #{value}")

      assert result == {:ok, 42}
      assert status == :ok
      assert value == 42
    end
  end

  describe "Pipe operator |>" do
    test "|> chains transformations left to right" do
      IO.puts("\n=== PIPE OPERATOR |> ===")
      result = Operators.pipe_example(42)
      IO.puts("42 |> to_string |> pad_leading(5,\"0\") => #{result}")

      assert result == "00042"
    end
  end
end

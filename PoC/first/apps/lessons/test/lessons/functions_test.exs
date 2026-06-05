defmodule SetmyInfo.Lessons.FunctionsTest do
  @moduledoc """
  Lesson: Elixir functions.

  Covers named functions, multi-clause dispatch, default params, anonymous
  functions, higher-order patterns, closures, captures, and recursion.
  """

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.Functions

  describe "Named functions" do
    test "simple named function" do
      IO.puts("\n=== NAMED FUNCTIONS ===")
      IO.puts(Functions.greet("Elixir"))
      assert Functions.greet("World") == "Hello, World!"
    end

    test "multi-clause function dispatches by pattern" do
      IO.puts("\n--- Multi-clause dispatch ---")

      Enum.each([0, 1, -5, 99], fn n ->
        IO.puts("describe(#{n}) => #{Functions.describe(n)}")
      end)

      assert Functions.describe(0) == "zero"
      assert Functions.describe(1) == "one"
      assert Functions.describe(-3) == "negative"
      assert Functions.describe(99) == "many"
    end

    test "default parameter values" do
      IO.puts("\n--- Default parameters ---")
      IO.puts(Functions.greet_with_title("Smith"))
      IO.puts(Functions.greet_with_title("Jones", "Dr."))

      assert Functions.greet_with_title("Smith") == "Hello, Mr/Ms Smith!"
      assert Functions.greet_with_title("Jones", "Dr.") == "Hello, Dr. Jones!"
    end
  end

  describe "Anonymous functions (lambdas)" do
    test "fn ... end syntax — called with dot notation" do
      IO.puts("\n=== ANONYMOUS FUNCTIONS ===")
      add5 = Functions.make_adder(5)
      doubler = Functions.make_doubler()
      IO.puts("make_adder(5).(10) => #{add5.(10)}")
      IO.puts("make_adder(5).(0)  => #{add5.(0)}")
      IO.puts("make_doubler().(7) => #{doubler.(7)}")

      assert add5.(10) == 15
      assert add5.(0) == 5
      assert doubler.(7) == 14
    end
  end

  describe "Functions as parameters (higher-order)" do
    test "apply_fn passes a unary function as an argument" do
      IO.puts("\n=== FUNCTIONS AS PARAMETERS ===")
      square = fn x -> x * x end
      IO.puts("apply square to 5  : #{Functions.apply_fn(square, 5)}")
      IO.puts("apply &+/2 to 3, 4 : #{Functions.apply_fn2(&+/2, 3, 4)}")

      assert Functions.apply_fn(square, 5) == 25
      assert Functions.apply_fn2(&+/2, 3, 4) == 7
      assert Functions.apply_fn2(&*/2, 3, 4) == 12
    end

    test "map_over transforms every element" do
      IO.puts("\n--- Higher-order map ---")
      triple = fn x -> x * 3 end
      result = Functions.map_over([1, 2, 3, 4], triple)
      IO.puts("triple each in [1,2,3,4]: #{inspect(result)}")

      assert result == [3, 6, 9, 12]
    end

    test "keep_if filters elements with a predicate" do
      IO.puts("\n--- Higher-order filter ---")
      result = Functions.keep_if([1, 2, 3, 4, 5, 6], fn x -> rem(x, 2) == 0 end)
      IO.puts("keep evens from [1..6]: #{inspect(result)}")

      assert result == [2, 4, 6]
    end
  end

  describe "Closures — functions that capture their scope" do
    test "multiplier returns a closure over factor" do
      IO.puts("\n=== CLOSURES ===")
      triple = Functions.multiplier(3)
      times10 = Functions.multiplier(10)
      IO.puts("triple.(5)  => #{triple.(5)}")
      IO.puts("times10.(7) => #{times10.(7)}")

      assert triple.(5) == 15
      assert triple.(0) == 0
      assert times10.(7) == 70
    end

    test "compose builds f(g(x)) — functions returning functions" do
      IO.puts("\n--- Function composition ---")
      add1 = fn x -> x + 1 end
      double = fn x -> x * 2 end
      add1_then_double = Functions.compose(double, add1)
      IO.puts("compose(double, add1).(4) => #{add1_then_double.(4)}")

      assert add1_then_double.(4) == 10
      assert add1_then_double.(0) == 2
    end
  end

  describe "Captured function references" do
    test "&Module.function/arity as a first-class value" do
      IO.puts("\n=== CAPTURED FUNCTIONS ===")
      lengths = Functions.string_lengths(["hi", "hello", "x"])
      IO.puts("string_lengths([\"hi\",\"hello\",\"x\"]): #{inspect(lengths)}")

      assert lengths == [2, 5, 1]
    end

    test "capture shorthand &(&1 * 2) replaces fn x -> x * 2 end" do
      IO.puts("\n--- Capture shorthand ---")
      result = Functions.double_all([1, 2, 3, 4, 5])
      IO.puts("double_all([1..5]): #{inspect(result)}")

      assert result == [2, 4, 6, 8, 10]
    end
  end

  describe "Recursion" do
    test "factorial — naive recursive" do
      IO.puts("\n=== RECURSION ===")

      Enum.each([0, 1, 5, 10], fn n ->
        IO.puts("#{n}! = #{Functions.factorial(n)}")
      end)

      assert Functions.factorial(0) == 1
      assert Functions.factorial(1) == 1
      assert Functions.factorial(5) == 120
      assert Functions.factorial(10) == 3_628_800
    end

    test "factorial_tail — tail-recursive, safe for large n" do
      IO.puts("\n--- Tail-recursive factorial ---")
      IO.puts("factorial_tail(10) = #{Functions.factorial_tail(10)}")

      assert Functions.factorial_tail(0) == 1
      assert Functions.factorial_tail(10) == 3_628_800
    end
  end
end

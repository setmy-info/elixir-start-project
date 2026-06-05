defmodule SetmyInfo.Lessons.FlowControlTest do
  @moduledoc "Lesson: Elixir flow control — if, cond, case, with, for, recursion."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.FlowControl

  describe "if / else" do
    test "even_or_odd uses if/else" do
      IO.puts("\n=== IF / ELSE ===")
      IO.puts("4 is #{FlowControl.even_or_odd(4)}")
      IO.puts("7 is #{FlowControl.even_or_odd(7)}")

      assert FlowControl.even_or_odd(4) == :even
      assert FlowControl.even_or_odd(7) == :odd
      assert FlowControl.even_or_odd(0) == :even
    end

    test "unless — runs when condition is false" do
      IO.puts("\n=== UNLESS ===")
      IO.puts("not logged in : #{FlowControl.unless_example(false)}")
      IO.puts("logged in     : #{FlowControl.unless_example(true)}")

      assert FlowControl.unless_example(false) == "Please log in"
      assert FlowControl.unless_example(true) == "Welcome!"
    end
  end

  describe "cond — multi-branch (if / elsif / else equivalent)" do
    test "grade computed from score" do
      IO.puts("\n=== COND (if-elsif-else equivalent) ===")

      Enum.each([95, 85, 75, 65, 55], fn score ->
        IO.puts("score #{score} => #{FlowControl.grade(score)}")
      end)

      assert FlowControl.grade(95) == "A"
      assert FlowControl.grade(82) == "B"
      assert FlowControl.grade(71) == "C"
      assert FlowControl.grade(60) == "D"
      assert FlowControl.grade(50) == "F"
    end
  end

  describe "case — structural pattern match" do
    test "HTTP status code description" do
      IO.puts("\n=== CASE ===")

      Enum.each([200, 201, 404, 500, 302], fn code ->
        IO.puts("#{code} => #{FlowControl.describe_http(code)}")
      end)

      assert FlowControl.describe_http(200) == "OK"
      assert FlowControl.describe_http(201) == "Created"
      assert FlowControl.describe_http(404) == "Not Found"
      assert FlowControl.describe_http(500) == "Server Error"
      assert FlowControl.describe_http(302) == "Unknown: 302"
    end

    test "case with guards — clauses can have when conditions" do
      IO.puts("\n--- case with guards ---")

      Enum.each([-5, 0, 5], fn n ->
        IO.puts("#{n} => #{FlowControl.number_sign(n)}")
      end)

      assert FlowControl.number_sign(-5) == :negative
      assert FlowControl.number_sign(0) == :zero
      assert FlowControl.number_sign(5) == :positive
    end
  end

  describe "with — chained happy-path matching" do
    test "safe_divide returns ok or error tuple" do
      IO.puts("\n=== WITH ===")
      IO.puts("10 / 2 => #{inspect(FlowControl.safe_divide(10, 2))}")
      IO.puts("10 / 0 => #{inspect(FlowControl.safe_divide(10, 0))}")

      assert FlowControl.safe_divide(10, 2) == {:ok, 5.0}
      assert FlowControl.safe_divide(10, 0) == {:error, :division_by_zero}
    end
  end

  describe "for comprehension — Elixir's functional loop" do
    test "squares: transform a range" do
      IO.puts("\n=== FOR COMPREHENSION ===")
      result = FlowControl.squares(5)
      IO.puts("squares 1..5: #{inspect(result)}")
      assert result == [1, 4, 9, 16, 25]
    end

    test "even_squares: comprehension with a filter clause" do
      IO.puts("\n--- for with filter ---")
      result = FlowControl.even_squares(6)
      IO.puts("even squares 1..6: #{inspect(result)}")
      assert result == [4, 16, 36]
    end

    test "pairs: multiple generators yield Cartesian product" do
      IO.puts("\n--- for with two generators ---")
      result = FlowControl.pairs([1, 2], [:a, :b])
      IO.puts("pairs([1,2], [:a,:b]): #{inspect(result)}")
      assert result == [{1, :a}, {1, :b}, {2, :a}, {2, :b}]
    end
  end

  describe "Recursion — replaces while / do-while loops" do
    test "sum_to uses naive recursion (like while n > 0)" do
      IO.puts("\n=== RECURSION (while substitute) ===")
      IO.puts("sum_to(10) => #{FlowControl.sum_to(10)}")
      IO.puts("sum_to(0)  => #{FlowControl.sum_to(0)}")

      assert FlowControl.sum_to(10) == 55
      assert FlowControl.sum_to(0) == 0
      assert FlowControl.sum_to(1) == 1
    end

    test "countdown uses tail recursion with accumulator" do
      IO.puts("\n--- tail-recursive countdown ---")
      result = FlowControl.countdown(5)
      IO.puts("countdown(5): #{inspect(result)}")
      assert result == [5, 4, 3, 2, 1]
      assert FlowControl.countdown(0) == []
    end
  end
end

defmodule SetmyInfo.Lessons.AlgorithmsTest do
  @moduledoc "Lesson: classic algorithms in idiomatic Elixir."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.Algorithms

  describe "Fibonacci" do
    test "naive recursive fib — exponential, fine for small n" do
      IO.puts("\n=== FIBONACCI (naive recursive) ===")

      Enum.each(0..10, fn n ->
        IO.write("fib(#{n})=#{Algorithms.fib(n)}  ")
      end)

      IO.puts("")

      assert Algorithms.fib(0) == 0
      assert Algorithms.fib(1) == 1
      assert Algorithms.fib(10) == 55
    end

    test "fib_fast — tail-recursive, safe for any n" do
      IO.puts("\n=== FIBONACCI (tail-recursive) ===")
      IO.puts("fib_fast(30) = #{Algorithms.fib_fast(30)}")
      IO.puts("fib_fast(50) = #{Algorithms.fib_fast(50)}")

      assert Algorithms.fib_fast(0) == 0
      assert Algorithms.fib_fast(1) == 1
      assert Algorithms.fib_fast(10) == 55
      assert Algorithms.fib_fast(30) == 832_040
    end

    test "fib_sequence — lazy stream, O(1) memory" do
      IO.puts("\n=== FIBONACCI (lazy stream) ===")
      seq = Algorithms.fib_sequence(10)
      IO.puts("first 10 fibs: #{inspect(seq)}")

      assert seq == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    end
  end

  describe "Factorial" do
    test "recursive factorial" do
      IO.puts("\n=== FACTORIAL ===")

      Enum.each([0, 1, 5, 7], fn n ->
        IO.puts("#{n}! = #{Algorithms.factorial(n)}")
      end)

      assert Algorithms.factorial(0) == 1
      assert Algorithms.factorial(5) == 120
      assert Algorithms.factorial(7) == 5040
    end
  end

  describe "List aggregation" do
    test "sum, max, min" do
      IO.puts("\n=== SUM / MAX / MIN ===")
      list = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
      IO.puts("list : #{inspect(list)}")
      IO.puts("sum  : #{Algorithms.sum(list)}")
      IO.puts("max  : #{Algorithms.max_of(list)}")
      IO.puts("min  : #{Algorithms.min_of(list)}")

      assert Algorithms.sum(list) == 39
      assert Algorithms.max_of(list) == 9
      assert Algorithms.min_of(list) == 1
    end
  end

  describe "Binary search" do
    test "finds element and returns its index" do
      IO.puts("\n=== BINARY SEARCH ===")
      sorted = [1, 3, 5, 7, 9, 11, 13, 15]
      IO.puts("list      : #{inspect(sorted)}")
      IO.puts("search 7  : #{inspect(Algorithms.binary_search(sorted, 7))}")
      IO.puts("search 1  : #{inspect(Algorithms.binary_search(sorted, 1))}")
      IO.puts("search 15 : #{inspect(Algorithms.binary_search(sorted, 15))}")
      IO.puts("search 6  : #{inspect(Algorithms.binary_search(sorted, 6))}")

      assert Algorithms.binary_search(sorted, 7) == {:ok, 3}
      assert Algorithms.binary_search(sorted, 1) == {:ok, 0}
      assert Algorithms.binary_search(sorted, 15) == {:ok, 7}
      assert Algorithms.binary_search(sorted, 6) == :not_found
    end
  end

  describe "List manipulation" do
    test "flatten — recursive implementation" do
      IO.puts("\n=== FLATTEN ===")
      nested = [1, [2, [3, 4]], [5, 6]]
      result = Algorithms.flatten(nested)
      IO.puts("nested  : #{inspect(nested)}")
      IO.puts("flat    : #{inspect(result)}")

      assert result == [1, 2, 3, 4, 5, 6]
      assert Algorithms.flatten([]) == []
    end

    test "reverse — tail-recursive" do
      IO.puts("\n=== REVERSE ===")
      IO.puts("[1,2,3] reversed: #{inspect(Algorithms.reverse([1, 2, 3]))}")

      assert Algorithms.reverse([1, 2, 3]) == [3, 2, 1]
      assert Algorithms.reverse([]) == []
      assert Algorithms.reverse([42]) == [42]
    end

    test "palindrome check" do
      IO.puts("\n=== PALINDROME ===")
      IO.puts("[1,2,1] palindrome? #{Algorithms.palindrome?([1, 2, 1])}")
      IO.puts("[1,2,3] palindrome? #{Algorithms.palindrome?([1, 2, 3])}")

      assert Algorithms.palindrome?([1, 2, 1]) == true
      assert Algorithms.palindrome?([]) == true
      assert Algorithms.palindrome?([1, 2, 3]) == false
    end

    test "count_occurrences" do
      IO.puts("\n=== COUNT OCCURRENCES ===")
      list = [1, 2, 3, 2, 1, 2]
      IO.puts("count 2 in #{inspect(list)}: #{Algorithms.count_occurrences(list, 2)}")

      assert Algorithms.count_occurrences(list, 2) == 3
      assert Algorithms.count_occurrences(list, 9) == 0
    end
  end

  describe "Number theory" do
    test "GCD — Euclid's algorithm" do
      IO.puts("\n=== GCD ===")
      IO.puts("gcd(48, 18) = #{Algorithms.gcd(48, 18)}")
      IO.puts("gcd(100, 75)= #{Algorithms.gcd(100, 75)}")

      assert Algorithms.gcd(48, 18) == 6
      assert Algorithms.gcd(100, 75) == 25
      assert Algorithms.gcd(7, 0) == 7
    end

    test "LCM" do
      IO.puts("\n=== LCM ===")
      IO.puts("lcm(4, 6) = #{Algorithms.lcm(4, 6)}")

      assert Algorithms.lcm(4, 6) == 12
      assert Algorithms.lcm(3, 5) == 15
    end

    test "prime check" do
      IO.puts("\n=== PRIME CHECK ===")
      primes = Enum.filter(2..20, &Algorithms.prime?/1)
      IO.puts("primes up to 20: #{inspect(primes)}")

      assert Algorithms.prime?(2) == true
      assert Algorithms.prime?(17) == true
      assert Algorithms.prime?(1) == false
      assert Algorithms.prime?(4) == false
      assert primes == [2, 3, 5, 7, 11, 13, 17, 19]
    end
  end
end

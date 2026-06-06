defmodule SetmyInfo.Lessons.AlgorithmsAndStreamsTest do
  @moduledoc "Lesson: algorithms and stream (lazy enumeration) patterns in Elixir."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.AlgorithmsAndStreams, as: Algo

  describe "Fibonacci" do
    test "naive recursive fib — exponential, fine for small n" do
      IO.puts("\n=== FIBONACCI (naive recursive) ===")

      Enum.each(0..10, fn n ->
        IO.write("fib(#{n})=#{Algo.fib(n)}  ")
      end)

      IO.puts("")

      assert Algo.fib(0) == 0
      assert Algo.fib(1) == 1
      assert Algo.fib(10) == 55
    end

    test "fib_fast — tail-recursive, safe for any n" do
      IO.puts("\n=== FIBONACCI (tail-recursive) ===")
      IO.puts("fib_fast(30) = #{Algo.fib_fast(30)}")
      IO.puts("fib_fast(50) = #{Algo.fib_fast(50)}")

      assert Algo.fib_fast(0) == 0
      assert Algo.fib_fast(1) == 1
      assert Algo.fib_fast(10) == 55
      assert Algo.fib_fast(30) == 832_040
    end

    test "fib_sequence — lazy stream, O(1) memory" do
      IO.puts("\n=== FIBONACCI (lazy stream) ===")
      seq = Algo.fib_sequence(10)
      IO.puts("first 10 fibs: #{inspect(seq)}")

      assert seq == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    end
  end

  describe "Factorial" do
    test "recursive factorial" do
      IO.puts("\n=== FACTORIAL ===")

      Enum.each([0, 1, 5, 7], fn n ->
        IO.puts("#{n}! = #{Algo.factorial(n)}")
      end)

      assert Algo.factorial(0) == 1
      assert Algo.factorial(5) == 120
      assert Algo.factorial(7) == 5040
    end
  end

  describe "List aggregation" do
    test "sum, max, min" do
      IO.puts("\n=== SUM / MAX / MIN ===")
      list = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
      IO.puts("list : #{inspect(list)}")
      IO.puts("sum  : #{Algo.sum(list)}")
      IO.puts("max  : #{Algo.max_of(list)}")
      IO.puts("min  : #{Algo.min_of(list)}")

      assert Algo.sum(list) == 39
      assert Algo.max_of(list) == 9
      assert Algo.min_of(list) == 1
    end
  end

  describe "Binary search" do
    test "finds element and returns its index" do
      IO.puts("\n=== BINARY SEARCH ===")
      sorted = [1, 3, 5, 7, 9, 11, 13, 15]
      IO.puts("list      : #{inspect(sorted)}")
      IO.puts("search 7  : #{inspect(Algo.binary_search(sorted, 7))}")
      IO.puts("search 6  : #{inspect(Algo.binary_search(sorted, 6))}")

      assert Algo.binary_search(sorted, 7) == {:ok, 3}
      assert Algo.binary_search(sorted, 1) == {:ok, 0}
      assert Algo.binary_search(sorted, 15) == {:ok, 7}
      assert Algo.binary_search(sorted, 6) == :not_found
    end
  end

  describe "List manipulation" do
    test "flatten — recursive implementation" do
      IO.puts("\n=== FLATTEN ===")
      nested = [1, [2, [3, 4]], [5, 6]]
      result = Algo.flatten(nested)
      IO.puts("nested  : #{inspect(nested)}")
      IO.puts("flat    : #{inspect(result)}")

      assert result == [1, 2, 3, 4, 5, 6]
      assert Algo.flatten([]) == []
    end

    test "reverse — tail-recursive" do
      IO.puts("\n=== REVERSE ===")
      IO.puts("[1,2,3] reversed: #{inspect(Algo.reverse([1, 2, 3]))}")

      assert Algo.reverse([1, 2, 3]) == [3, 2, 1]
      assert Algo.reverse([]) == []
      assert Algo.reverse([42]) == [42]
    end

    test "palindrome check" do
      IO.puts("\n=== PALINDROME ===")
      IO.puts("[1,2,1] palindrome? #{Algo.palindrome?([1, 2, 1])}")
      IO.puts("[1,2,3] palindrome? #{Algo.palindrome?([1, 2, 3])}")

      assert Algo.palindrome?([1, 2, 1]) == true
      assert Algo.palindrome?([]) == true
      assert Algo.palindrome?([1, 2, 3]) == false
    end

    test "count_occurrences" do
      IO.puts("\n=== COUNT OCCURRENCES ===")
      list = [1, 2, 3, 2, 1, 2]
      IO.puts("count 2 in #{inspect(list)}: #{Algo.count_occurrences(list, 2)}")

      assert Algo.count_occurrences(list, 2) == 3
      assert Algo.count_occurrences(list, 9) == 0
    end
  end

  describe "Number theory" do
    test "GCD — Euclid's algorithm" do
      IO.puts("\n=== GCD ===")
      IO.puts("gcd(48, 18) = #{Algo.gcd(48, 18)}")

      assert Algo.gcd(48, 18) == 6
      assert Algo.gcd(100, 75) == 25
      assert Algo.gcd(7, 0) == 7
    end

    test "LCM" do
      IO.puts("\n=== LCM ===")
      IO.puts("lcm(4, 6) = #{Algo.lcm(4, 6)}")

      assert Algo.lcm(4, 6) == 12
      assert Algo.lcm(3, 5) == 15
    end

    test "prime check" do
      IO.puts("\n=== PRIME CHECK ===")
      primes = Enum.filter(2..20, &Algo.prime?/1)
      IO.puts("primes up to 20: #{inspect(primes)}")

      assert Algo.prime?(2) == true
      assert Algo.prime?(17) == true
      assert Algo.prime?(1) == false
      assert Algo.prime?(4) == false
      assert primes == [2, 3, 5, 7, 11, 13, 17, 19]
    end
  end

  describe "Enum pipeline patterns (Java stream analogue)" do
    test "map: double every element" do
      IO.puts("\n=== ENUM PIPELINES ===")
      list = [1, 2, 3, 4, 5]
      result = Algo.map_list(list, &(&1 * 2))
      IO.puts("map double #{inspect(list)} => #{inspect(result)}")

      assert result == [2, 4, 6, 8, 10]
    end

    test "filter: keep only even numbers" do
      list = [1, 2, 3, 4, 5, 6]
      result = Algo.filter_list(list, fn x -> rem(x, 2) == 0 end)
      IO.puts("filter evens #{inspect(list)} => #{inspect(result)}")

      assert result == [2, 4, 6]
    end

    test "reject: remove negative numbers" do
      list = [-2, -1, 0, 1, 2]
      result = Algo.reject_list(list, fn x -> x < 0 end)
      IO.puts("reject negatives #{inspect(list)} => #{inspect(result)}")

      assert result == [0, 1, 2]
    end

    test "reduce: sum a list" do
      list = [1, 2, 3, 4, 5]
      result = Algo.reduce_list(list, 0, &+/2)
      IO.puts("reduce sum #{inspect(list)} => #{result}")

      assert result == 15
    end

    test "sort: ascending, descending, sort_by" do
      list = [3, 1, 4, 1, 5, 9, 2, 6]
      IO.puts("sort asc  #{inspect(list)} => #{inspect(Algo.sort_asc(list))}")
      IO.puts("sort desc #{inspect(list)} => #{inspect(Algo.sort_desc(list))}")

      assert Algo.sort_asc(list) == [1, 1, 2, 3, 4, 5, 6, 9]
      assert Algo.sort_desc(list) == [9, 6, 5, 4, 3, 2, 1, 1]

      words = ["banana", "fig", "apple", "kiwi"]
      by_len = Algo.sort_by(words, &String.length/1)
      IO.puts("sort by length #{inspect(words)} => #{inspect(by_len)}")
      assert by_len == ["fig", "kiwi", "apple", "banana"]
    end

    test "flat_map: expand each element" do
      list = [1, 2, 3]
      result = Algo.flat_map(list, fn x -> [x, x * 10] end)
      IO.puts("flat_map #{inspect(list)} => #{inspect(result)}")

      assert result == [1, 10, 2, 20, 3, 30]
    end

    test "group_by: bucket by parity" do
      list = [1, 2, 3, 4, 5, 6]
      groups = Algo.group_by(list, fn x -> if rem(x, 2) == 0, do: :even, else: :odd end)
      IO.puts("group_by parity #{inspect(list)} => #{inspect(groups)}")

      assert groups[:even] == [2, 4, 6]
      assert groups[:odd] == [1, 3, 5]
    end

    test "zip: pair two lists" do
      a = [1, 2, 3]
      b = [:a, :b, :c]
      result = Algo.zip_lists(a, b)
      IO.puts("zip #{inspect(a)} #{inspect(b)} => #{inspect(result)}")

      assert result == [{1, :a}, {2, :b}, {3, :c}]
    end

    test "predicates: any?, all?, find_first" do
      list = [1, 2, 3, 4, 5]
      IO.puts("\n--- Predicates ---")
      IO.puts("any > 3?   => #{Algo.any_match?(list, &(&1 > 3))}")
      IO.puts("all > 0?   => #{Algo.all_match?(list, &(&1 > 0))}")
      IO.puts("find > 3   => #{Algo.find_first(list, &(&1 > 3))}")

      assert Algo.any_match?(list, &(&1 > 3)) == true
      assert Algo.all_match?(list, &(&1 > 0)) == true
      assert Algo.all_match?(list, &(&1 > 3)) == false
      assert Algo.find_first(list, &(&1 > 3)) == 4
      assert Algo.count_matching(list, &(&1 > 3)) == 2
    end
  end

  describe "Stream (lazy enumeration)" do
    test "first_n_doubles via infinite Stream.iterate" do
      IO.puts("\n=== STREAMS (lazy) ===")
      result = Algo.first_n_doubles(5)
      IO.puts("first 5 doubles of naturals: #{inspect(result)}")

      assert result == [2, 4, 6, 8, 10]
    end

    test "first_n_squares via infinite Stream.iterate" do
      result = Algo.first_n_squares(6)
      IO.puts("first 6 perfect squares: #{inspect(result)}")

      assert result == [1, 4, 9, 16, 25, 36]
    end

    test "first_n_fibs via Stream.unfold" do
      result = Algo.first_n_fibs(10)
      IO.puts("first 10 Fibonacci numbers: #{inspect(result)}")

      assert result == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    end

    test "lazy_map_filter defers evaluation — no intermediate lists" do
      list = Enum.to_list(1..100)
      result = Algo.lazy_map_filter(list, &(&1 * &1), &(&1 < 50))
      IO.puts("lazy: squares < 50 from 1..100: #{inspect(result)}")

      assert result == [1, 4, 9, 16, 25, 36, 49]
    end
  end
end

defmodule SetmyInfo.Lessons.Algorithms do
  @moduledoc """
  Classic algorithm examples in idiomatic Elixir.

  Demonstrates recursion, pattern matching, guards, and the `Stream` module
  as alternatives to imperative loops.

  ## Algorithms covered

  - Fibonacci (naive recursive, tail-recursive, lazy stream)
  - Factorial
  - List sum / max / min
  - Binary search
  - List flatten, reverse, palindrome
  - GCD / LCM (Euclid)
  - Prime check
  """

  # ──────────────────── Fibonacci ─────────────────────────────────────────────

  @doc """
  Fibonacci — naive recursive.
  Exponential time complexity O(2^n) — only practical for small n.

      iex> SetmyInfo.Lessons.Algorithms.fib(10)
      55
  """
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n > 1, do: fib(n - 1) + fib(n - 2)

  @doc """
  Fibonacci — tail-recursive accumulator pattern.
  O(n) time, O(1) stack depth — safe for any n.

      iex> SetmyInfo.Lessons.Algorithms.fib_fast(30)
      832040
  """
  def fib_fast(n), do: fib_acc(n, 0, 1)
  defp fib_acc(0, a, _), do: a
  defp fib_acc(n, a, b), do: fib_acc(n - 1, b, a + b)

  @doc """
  Generate a Fibonacci sequence of `n` terms using a lazy `Stream`.

      iex> SetmyInfo.Lessons.Algorithms.fib_sequence(8)
      [0, 1, 1, 2, 3, 5, 8, 13]
  """
  def fib_sequence(n) when n >= 1 do
    Stream.unfold({0, 1}, fn {a, b} -> {a, {b, a + b}} end)
    |> Enum.take(n)
  end

  # ──────────────────── Factorial ─────────────────────────────────────────────

  @doc """
  Factorial — recursive.

      iex> SetmyInfo.Lessons.Algorithms.factorial(5)
      120
  """
  def factorial(0), do: 1
  def factorial(n) when n > 0, do: n * factorial(n - 1)

  # ──────────────────── List aggregation ──────────────────────────────────────

  @doc "Sum all elements using `Enum.reduce`."
  def sum(list), do: Enum.reduce(list, 0, &+/2)

  @doc "Maximum element."
  def max_of(list), do: Enum.max(list)

  @doc "Minimum element."
  def min_of(list), do: Enum.min(list)

  # ──────────────────── Binary search ─────────────────────────────────────────

  @doc """
  Binary search on a sorted list.
  Returns `{:ok, index}` or `:not_found`.

  Note: `Enum.at/2` is O(n), so this is O(n log n) overall.
  For O(log n) binary search use a tuple or `:array` module instead.
  """
  def binary_search(sorted_list, target) do
    do_binary_search(sorted_list, target, 0, length(sorted_list) - 1)
  end

  defp do_binary_search(_list, _target, low, high) when low > high, do: :not_found

  defp do_binary_search(list, target, low, high) do
    mid = div(low + high, 2)
    val = Enum.at(list, mid)

    cond do
      val == target -> {:ok, mid}
      val < target -> do_binary_search(list, target, mid + 1, high)
      true -> do_binary_search(list, target, low, mid - 1)
    end
  end

  # ──────────────────── List manipulation ─────────────────────────────────────

  @doc """
  Flatten a nested list — custom recursive implementation.

      iex> SetmyInfo.Lessons.Algorithms.flatten([1, [2, [3, 4]], [5]])
      [1, 2, 3, 4, 5]
  """
  def flatten([]), do: []
  def flatten([h | t]) when is_list(h), do: flatten(h) ++ flatten(t)
  def flatten([h | t]), do: [h | flatten(t)]

  @doc """
  Reverse a list — tail-recursive.

      iex> SetmyInfo.Lessons.Algorithms.reverse([1, 2, 3])
      [3, 2, 1]
  """
  def reverse(list), do: do_reverse(list, [])
  defp do_reverse([], acc), do: acc
  defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])

  @doc "Count occurrences of `value` in `list`."
  def count_occurrences(list, value) do
    Enum.count(list, fn x -> x == value end)
  end

  @doc "Check if a list reads the same forwards and backwards."
  def palindrome?(list), do: list == reverse(list)

  # ──────────────────── Number theory ─────────────────────────────────────────

  @doc """
  Greatest Common Divisor — Euclid's algorithm.

      iex> SetmyInfo.Lessons.Algorithms.gcd(48, 18)
      6
  """
  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))

  @doc """
  Least Common Multiple.

      iex> SetmyInfo.Lessons.Algorithms.lcm(4, 6)
      12
  """
  def lcm(a, b), do: div(a * b, gcd(a, b))

  @doc """
  Primality test — trial division up to √n.

      iex> SetmyInfo.Lessons.Algorithms.prime?(17)
      true
  """
  def prime?(n) when n < 2, do: false
  def prime?(2), do: true
  def prime?(n) when rem(n, 2) == 0, do: false
  def prime?(n), do: prime_check(n, 3)

  defp prime_check(n, i) when i * i > n, do: true
  defp prime_check(n, i) when rem(n, i) == 0, do: false
  defp prime_check(n, i), do: prime_check(n, i + 2)
end

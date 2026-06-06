defmodule SetmyInfo.Lessons.AlgorithmsAndStreams do
  @moduledoc """
  Classic algorithm examples and stream (lazy enumeration) patterns in idiomatic Elixir.

  Demonstrates recursion, pattern matching, guards, `Enum`, and the `Stream` module
  as an alternative to imperative loops and Java-style `Stream` pipelines.

  ## Algorithms covered

  - Fibonacci (naive recursive, tail-recursive, lazy stream)
  - Factorial
  - List sum / max / min
  - Binary search
  - List flatten, reverse, palindrome
  - GCD / LCM (Euclid)
  - Prime check

  ## Stream / Enum pipeline patterns

  `Enum` is eager — it evaluates the whole collection at each step.
  `Stream` is lazy — it builds a description of transformations, evaluated only when
  consumed (e.g. by `Enum.to_list/1` or `Enum.take/2`). Use `Stream` for:
  - Infinite sequences (can't hold them in memory)
  - Large collections where early termination saves work
  - Chaining many transformations without intermediate lists

  Java `stream().map().filter().collect()` maps to Elixir as:
  ```elixir
  list
  |> Stream.map(&transform/1)
  |> Stream.filter(&keep?/1)
  |> Enum.to_list()
  ```
  """

  # ──────────────────── Fibonacci ─────────────────────────────────────────────

  @doc """
  Fibonacci — naive recursive.
  Exponential time complexity O(2^n) — only practical for small n.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.fib(10)
      55
  """
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n > 1, do: fib(n - 1) + fib(n - 2)

  @doc """
  Fibonacci — tail-recursive accumulator pattern.
  O(n) time, O(1) stack depth — safe for any n.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.fib_fast(30)
      832040
  """
  def fib_fast(n), do: fib_acc(n, 0, 1)
  defp fib_acc(0, a, _), do: a
  defp fib_acc(n, a, b), do: fib_acc(n - 1, b, a + b)

  @doc """
  Generate a Fibonacci sequence of `n` terms using a lazy `Stream`.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.fib_sequence(8)
      [0, 1, 1, 2, 3, 5, 8, 13]
  """
  def fib_sequence(n) when n >= 1 do
    Stream.unfold({0, 1}, fn {a, b} -> {a, {b, a + b}} end)
    |> Enum.take(n)
  end

  # ──────────────────── Factorial ─────────────────────────────────────────────

  @doc """
  Factorial — recursive.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.factorial(5)
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

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.flatten([1, [2, [3, 4]], [5]])
      [1, 2, 3, 4, 5]
  """
  def flatten([]), do: []
  def flatten([h | t]) when is_list(h), do: flatten(h) ++ flatten(t)
  def flatten([h | t]), do: [h | flatten(t)]

  @doc """
  Reverse a list — tail-recursive.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.reverse([1, 2, 3])
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

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.gcd(48, 18)
      6
  """
  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))

  @doc """
  Least Common Multiple.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.lcm(4, 6)
      12
  """
  def lcm(a, b), do: div(a * b, gcd(a, b))

  @doc """
  Primality test — trial division up to √n.

      iex> SetmyInfo.Lessons.AlgorithmsAndStreams.prime?(17)
      true
  """
  def prime?(n) when n < 2, do: false
  def prime?(2), do: true
  def prime?(n) when rem(n, 2) == 0, do: false
  def prime?(n), do: prime_check(n, 3)

  defp prime_check(n, i) when i * i > n, do: true
  defp prime_check(n, i) when rem(n, i) == 0, do: false
  defp prime_check(n, i), do: prime_check(n, i + 2)

  # ──────────────────── Enum pipeline patterns (Java stream analogue) ──────────

  @doc """
  Map: apply `f` to every element — Java `stream().map(f).collect()`.
  """
  def map_list(list, f), do: Enum.map(list, f)

  @doc """
  Filter: keep elements matching predicate — Java `stream().filter(p).collect()`.
  """
  def filter_list(list, predicate), do: Enum.filter(list, predicate)

  @doc """
  Reject: remove elements matching predicate (inverse of filter).
  """
  def reject_list(list, predicate), do: Enum.reject(list, predicate)

  @doc """
  Reduce (fold): collapse a list to a single value — Java `stream().reduce()`.
  """
  def reduce_list(list, initial, f), do: Enum.reduce(list, initial, f)

  @doc """
  Sort: ascending natural order — Java `stream().sorted().collect()`.
  """
  def sort_asc(list), do: Enum.sort(list)

  @doc """
  Sort descending.
  """
  def sort_desc(list), do: Enum.sort(list, :desc)

  @doc """
  Sort by a derived key — Java `stream().sorted(Comparator.comparing(f))`.
  """
  def sort_by(list, key_fn), do: Enum.sort_by(list, key_fn)

  @doc """
  Lazy map + filter pipeline using `Stream`.

  No intermediate list is created. Computation is deferred until `Enum.to_list/1`
  (or another eager terminator) is called. Equivalent to Java lazy streams.
  """
  def lazy_map_filter(list, map_fn, filter_fn) do
    list
    |> Stream.map(map_fn)
    |> Stream.filter(filter_fn)
    |> Enum.to_list()
  end

  @doc """
  Take the first `n` elements from an infinite stream of natural numbers,
  doubled.

  `Stream.iterate/2` generates an infinite sequence — never realized in full.
  `Enum.take/2` terminates the lazy evaluation.
  """
  def first_n_doubles(n) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&(&1 * 2))
    |> Enum.take(n)
  end

  @doc """
  First `n` perfect squares from an infinite lazy stream.
  """
  def first_n_squares(n) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&(&1 * &1))
    |> Enum.take(n)
  end

  @doc """
  First `n` Fibonacci numbers from an infinite lazy `Stream.unfold`.

  `Stream.unfold/2` is the Elixir equivalent of Java's `Stream.iterate/2`
  with a two-element state tuple.
  """
  def first_n_fibs(n) do
    Stream.unfold({0, 1}, fn {a, b} -> {a, {b, a + b}} end)
    |> Enum.take(n)
  end

  @doc """
  Group elements by a derived key — Java `stream().collect(groupingBy(f))`.
  """
  def group_by(list, key_fn), do: Enum.group_by(list, key_fn)

  @doc """
  Flat-map: map then flatten one level — Java `stream().flatMap(f).collect()`.
  """
  def flat_map(list, f), do: Enum.flat_map(list, f)

  @doc """
  Zip two lists into pairs — Java `IntStream.range(0,n).mapToObj(i -> pair(a[i],b[i]))`.
  """
  def zip_lists(a, b), do: Enum.zip(a, b)

  @doc """
  Count elements matching a predicate — Java `stream().filter(p).count()`.
  """
  def count_matching(list, predicate), do: Enum.count(list, predicate)

  @doc """
  Check if any element matches — Java `stream().anyMatch(p)`.
  """
  def any_match?(list, predicate), do: Enum.any?(list, predicate)

  @doc """
  Check if all elements match — Java `stream().allMatch(p)`.
  """
  def all_match?(list, predicate), do: Enum.all?(list, predicate)

  @doc """
  Find first matching element — Java `stream().filter(p).findFirst()`.
  Returns the element or `nil` (not `Optional`).
  """
  def find_first(list, predicate), do: Enum.find(list, predicate)
end

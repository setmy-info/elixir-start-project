defmodule SetmyInfo.Lessons.Collections do
  @moduledoc """
  Demonstrates collection operations on Lists and Maps.

  ## Enum functions covered

  `map`, `filter`, `reject`, `reduce`, `each`, `any?`, `all?`, `find`,
  `sort`, `sort_by`, `zip`, `flat_map`, `group_by`, `chunk_every`,
  `uniq`, `take`, `count`, `frequencies` (via reduce)

  ## Map module covered

  `keys`, `values`, `has_key?`, `merge`, `to_list`, `new`

  ## Stream (lazy)

  `Stream.iterate`, `Stream.unfold`, `Stream.map` — for infinite or large sequences.
  """

  # ──────────────────── List mapping ──────────────────────────────────────────

  @doc "Map: double every element."
  def double_list(list), do: Enum.map(list, fn x -> x * 2 end)

  @doc "Map with a captured function reference."
  def stringify_list(list), do: Enum.map(list, &Integer.to_string/1)

  # ──────────────────── List filtering ────────────────────────────────────────

  @doc "Filter: keep only even numbers."
  def keep_evens(list), do: Enum.filter(list, fn x -> rem(x, 2) == 0 end)

  @doc "Reject: remove negative numbers."
  def reject_negatives(list), do: Enum.reject(list, fn x -> x < 0 end)

  # ──────────────────── Reduce ─────────────────────────────────────────────────

  @doc "Fold a list to a single sum."
  def sum(list), do: Enum.reduce(list, 0, fn x, acc -> x + acc end)

  @doc "Build a frequency map via reduce."
  def frequencies(list) do
    Enum.reduce(list, %{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1))
    end)
  end

  # ──────────────────── Side effects ──────────────────────────────────────────

  @doc "each: apply a side-effecting function to every element; returns `:ok`."
  def print_each(list), do: Enum.each(list, &IO.puts/1)

  # ──────────────────── Predicates ────────────────────────────────────────────

  @doc "any?: true if at least one element satisfies the predicate."
  def any_negative?(list), do: Enum.any?(list, fn x -> x < 0 end)

  @doc "all?: true if every element satisfies the predicate."
  def all_positive?(list), do: Enum.all?(list, fn x -> x > 0 end)

  @doc "find: first matching element, or `nil` if none."
  def find_first_even(list), do: Enum.find(list, fn x -> rem(x, 2) == 0 end)

  # ──────────────────── Sorting ────────────────────────────────────────────────

  @doc "Sort ascending (natural order)."
  def sort_asc(list), do: Enum.sort(list)

  @doc "Sort descending."
  def sort_desc(list), do: Enum.sort(list, :desc)

  @doc "Sort strings by their length."
  def sort_by_length(strings), do: Enum.sort_by(strings, &String.length/1)

  # ──────────────────── Transformations ────────────────────────────────────────

  @doc "zip: pair elements from two lists into tuples."
  def zip_lists(a, b), do: Enum.zip(a, b)

  @doc "flat_map: map then flatten one level — expands each element."
  def expand(list), do: Enum.flat_map(list, fn x -> [x, x * 2] end)

  @doc "group_by: bucket elements by a derived key."
  def group_by_parity(list) do
    Enum.group_by(list, fn x ->
      if rem(x, 2) == 0, do: :even, else: :odd
    end)
  end

  @doc "take: first `n` elements."
  def take_n(list, n), do: Enum.take(list, n)

  @doc "chunk_every: split into sub-lists of size `n`."
  def chunk(list, n), do: Enum.chunk_every(list, n)

  @doc "uniq: remove duplicate elements preserving first-seen order."
  def unique(list), do: Enum.uniq(list)

  @doc "List.flatten: recursively flatten nested lists."
  def flatten(list), do: List.flatten(list)

  # ──────────────────── Map operations ─────────────────────────────────────────

  @doc "Return all keys of a map."
  def map_keys(m), do: Map.keys(m)

  @doc "Return all values of a map."
  def map_values(m), do: Map.values(m)

  @doc "Check whether a key exists in a map."
  def map_has_key?(m, k), do: Map.has_key?(m, k)

  @doc "Merge two maps — right-hand keys win on conflict."
  def map_merge(m1, m2), do: Map.merge(m1, m2)

  @doc "Merge with a conflict resolver — sum values for duplicate keys."
  def map_merge_sum(m1, m2) do
    Map.merge(m1, m2, fn _key, v1, v2 -> v1 + v2 end)
  end

  @doc "Convert a map to a list of `{key, value}` pairs."
  def map_to_list(m), do: Map.to_list(m)

  @doc "Filter map entries, keeping only those with positive values."
  def map_filter_positives(m) do
    m
    |> Enum.filter(fn {_k, v} -> v > 0 end)
    |> Map.new()
  end

  @doc "Transform every value in a map with function `f`."
  def map_transform_values(m, f) do
    Map.new(m, fn {k, v} -> {k, f.(v)} end)
  end

  # ──────────────────── Streams (lazy) ─────────────────────────────────────────

  @doc "Take first `n` perfect squares from an infinite lazy stream."
  def first_n_squares(n) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&(&1 * &1))
    |> Enum.take(n)
  end

  @doc "Take first `n` Fibonacci numbers from an infinite lazy stream."
  def first_n_fibs(n) do
    Stream.unfold({0, 1}, fn {a, b} -> {a, {b, a + b}} end)
    |> Enum.take(n)
  end
end

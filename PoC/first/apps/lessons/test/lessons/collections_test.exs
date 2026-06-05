defmodule SetmyInfo.Lessons.CollectionsTest do
  @moduledoc "Lesson: Enum, Map, and Stream operations on lists and maps."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.Collections

  describe "List mapping" do
    test "Enum.map transforms every element" do
      IO.puts("\n=== LIST MAPPING ===")
      list = [1, 2, 3, 4, 5]
      IO.puts("original    : #{inspect(list)}")
      IO.puts("doubled     : #{inspect(Collections.double_list(list))}")
      IO.puts("stringified : #{inspect(Collections.stringify_list(list))}")

      assert Collections.double_list([1, 2, 3]) == [2, 4, 6]
      assert Collections.stringify_list([1, 2, 3]) == ["1", "2", "3"]
    end
  end

  describe "List filtering" do
    test "Enum.filter and Enum.reject" do
      IO.puts("\n=== LIST FILTERING ===")
      list = [-3, -1, 0, 2, 4, 5, 7]
      IO.puts("original          : #{inspect(list)}")
      IO.puts("keep evens        : #{inspect(Collections.keep_evens(list))}")
      IO.puts("reject negatives  : #{inspect(Collections.reject_negatives(list))}")

      assert Collections.keep_evens([1, 2, 3, 4, 5]) == [2, 4]
      assert Collections.reject_negatives([-1, 0, 1, 2]) == [0, 1, 2]
    end
  end

  describe "Reduce" do
    test "Enum.reduce folds a list to a single value" do
      IO.puts("\n=== REDUCE ===")
      list = [1, 2, 3, 4, 5]
      IO.puts("sum #{inspect(list)} = #{Collections.sum(list)}")

      assert Collections.sum([1, 2, 3, 4, 5]) == 15
      assert Collections.sum([]) == 0
    end

    test "reduce builds a frequency map" do
      IO.puts("\n--- Frequencies via reduce ---")
      list = [:a, :b, :a, :c, :b, :a]
      result = Collections.frequencies(list)
      IO.puts("frequencies: #{inspect(result)}")

      assert result == %{a: 3, b: 2, c: 1}
    end
  end

  describe "Predicates" do
    test "any?, all?, find" do
      IO.puts("\n=== PREDICATES ===")
      list = [1, -2, 3, -4]
      IO.puts("any negative?     : #{Collections.any_negative?(list)}")
      IO.puts("all positive?     : #{Collections.all_positive?(list)}")
      IO.puts("all pos [1,2,3]?  : #{Collections.all_positive?([1, 2, 3])}")
      IO.puts("find first even   : #{inspect(Collections.find_first_even(list))}")

      assert Collections.any_negative?(list) == true
      assert Collections.any_negative?([1, 2, 3]) == false
      assert Collections.all_positive?([1, 2, 3]) == true
      assert Collections.all_positive?(list) == false
      assert Collections.find_first_even([1, 3, 4, 5]) == 4
      assert Collections.find_first_even([1, 3, 5]) == nil
    end
  end

  describe "Sorting" do
    test "sort ascending, descending, and by derived key" do
      IO.puts("\n=== SORTING ===")
      nums = [3, 1, 4, 1, 5, 9]
      words = ["banana", "apple", "kiwi", "fig"]
      IO.puts("asc       : #{inspect(Collections.sort_asc(nums))}")
      IO.puts("desc      : #{inspect(Collections.sort_desc(nums))}")
      IO.puts("by length : #{inspect(Collections.sort_by_length(words))}")

      assert Collections.sort_asc([3, 1, 2]) == [1, 2, 3]
      assert Collections.sort_desc([1, 3, 2]) == [3, 2, 1]
      assert Collections.sort_by_length(["bb", "a", "ccc"]) == ["a", "bb", "ccc"]
    end
  end

  describe "Zip and flat_map" do
    test "zip pairs elements from two lists" do
      IO.puts("\n=== ZIP ===")
      result = Collections.zip_lists([1, 2, 3], [:a, :b, :c])
      IO.puts("zipped: #{inspect(result)}")

      assert result == [{1, :a}, {2, :b}, {3, :c}]
    end

    test "flat_map expands each element into multiple" do
      IO.puts("\n=== FLAT_MAP ===")
      result = Collections.expand([1, 2, 3])
      IO.puts("expand [1,2,3]: #{inspect(result)}")

      assert result == [1, 2, 2, 4, 3, 6]
    end
  end

  describe "group_by and chunk_every" do
    test "group_by buckets elements by a key function" do
      IO.puts("\n=== GROUP_BY ===")
      result = Collections.group_by_parity([1, 2, 3, 4, 5, 6])
      IO.puts("grouped: #{inspect(result)}")

      assert result == %{even: [2, 4, 6], odd: [1, 3, 5]}
    end

    test "chunk_every splits into fixed-size sub-lists" do
      IO.puts("\n=== CHUNK_EVERY ===")
      result = Collections.chunk([1, 2, 3, 4, 5, 6], 2)
      IO.puts("chunk by 2: #{inspect(result)}")

      assert result == [[1, 2], [3, 4], [5, 6]]
    end
  end

  describe "uniq and flatten" do
    test "uniq removes duplicates preserving order" do
      IO.puts("\n=== UNIQ ===")
      result = Collections.unique([1, 2, 2, 3, 3, 3])
      IO.puts("unique: #{inspect(result)}")

      assert result == [1, 2, 3]
    end

    test "List.flatten flattens any depth" do
      IO.puts("\n=== FLATTEN ===")
      result = Collections.flatten([1, [2, 3], [4, [5, 6]]])
      IO.puts("flattened: #{inspect(result)}")

      assert result == [1, 2, 3, 4, 5, 6]
    end
  end

  describe "Map module operations" do
    test "keys, values, has_key?" do
      IO.puts("\n=== MAP OPERATIONS ===")
      m = %{a: 1, b: 2, c: 3}
      IO.puts("map    : #{inspect(m)}")
      IO.puts("keys   : #{inspect(Enum.sort(Collections.map_keys(m)))}")
      IO.puts("values : #{inspect(Enum.sort(Collections.map_values(m)))}")
      IO.puts("has :a?: #{Collections.map_has_key?(m, :a)}")
      IO.puts("has :z?: #{Collections.map_has_key?(m, :z)}")

      assert Enum.sort(Collections.map_keys(m)) == [:a, :b, :c]
      assert Enum.sort(Collections.map_values(m)) == [1, 2, 3]
      assert Collections.map_has_key?(m, :a) == true
      assert Collections.map_has_key?(m, :z) == false
    end

    test "merge — right wins; merge_sum uses conflict resolver" do
      IO.puts("\n--- Map merge ---")
      m1 = %{a: 1, b: 2}
      m2 = %{b: 10, c: 3}
      IO.puts("merge (right wins): #{inspect(Collections.map_merge(m1, m2))}")
      IO.puts("merge sum         : #{inspect(Collections.map_merge_sum(m1, m2))}")

      assert Collections.map_merge(m1, m2) == %{a: 1, b: 10, c: 3}
      assert Collections.map_merge_sum(m1, m2) == %{a: 1, b: 12, c: 3}
    end

    test "filter map by value and transform values" do
      IO.puts("\n--- Map filter and transform ---")
      m = %{a: 1, b: -2, c: 3, d: -4}
      pos = Collections.map_filter_positives(m)
      doubled = Collections.map_transform_values(m, &(&1 * 2))
      IO.puts("filter positives : #{inspect(pos)}")
      IO.puts("double values    : #{inspect(doubled)}")

      assert pos == %{a: 1, c: 3}
      assert doubled == %{a: 2, b: -4, c: 6, d: -8}
    end
  end

  describe "Streams — lazy evaluation" do
    test "first_n_squares from an infinite stream" do
      IO.puts("\n=== STREAMS (lazy) ===")
      result = Collections.first_n_squares(5)
      IO.puts("first 5 squares: #{inspect(result)}")

      assert result == [1, 4, 9, 16, 25]
    end

    test "first_n_fibs from an infinite Fibonacci stream" do
      IO.puts("\n--- Fibonacci stream ---")
      result = Collections.first_n_fibs(8)
      IO.puts("first 8 Fibonacci: #{inspect(result)}")

      assert result == [0, 1, 1, 2, 3, 5, 8, 13]
    end
  end
end

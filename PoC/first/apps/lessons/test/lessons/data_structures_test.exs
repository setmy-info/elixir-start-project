defmodule SetmyInfo.Lessons.DataStructuresTest do
  @moduledoc "Lesson: Elixir composite data structures."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.DataStructures
  alias SetmyInfo.Lessons.DataStructures.Person

  describe "Tuples" do
    test "pair and triple — fixed-size, fast element access" do
      IO.puts("\n=== TUPLES ===")
      pair = DataStructures.tuple_pair()
      triple = DataStructures.tuple_triple()
      IO.puts("pair   : #{inspect(pair)}")
      IO.puts("triple : #{inspect(triple)}")
      IO.puts("elem(pair, 0) => #{DataStructures.tuple_elem(pair, 0)}")
      IO.puts("elem(pair, 1) => #{DataStructures.tuple_elem(pair, 1)}")
      IO.puts("size of pair  => #{DataStructures.get_tuple_size(pair)}")

      assert pair == {:ok, 42}
      assert triple == {:error, :not_found, "resource missing"}
      assert DataStructures.tuple_elem(pair, 0) == :ok
      assert DataStructures.tuple_elem(pair, 1) == 42
      assert DataStructures.get_tuple_size(pair) == 2
      assert DataStructures.get_tuple_size(triple) == 3
    end

    test "pattern matching tuples — idiomatic Elixir error handling" do
      IO.puts("\n--- Tuple pattern match ---")
      {:ok, value} = DataStructures.tuple_pair()
      IO.puts("matched value from {:ok, value}: #{value}")
      assert value == 42
    end
  end

  describe "Lists" do
    test "creation and basic operations" do
      IO.puts("\n=== LISTS ===")
      list = DataStructures.list_integers()
      mixed = DataStructures.list_mixed()
      IO.puts("integers : #{inspect(list)}")
      IO.puts("mixed    : #{inspect(mixed)}")
      IO.puts("prepend 0: #{inspect(DataStructures.list_prepend(0, list))}")
      IO.puts("head     : #{DataStructures.list_head(list)}")
      IO.puts("tail     : #{inspect(DataStructures.list_tail(list))}")
      IO.puts("[1,2]++[3,4]: #{inspect(DataStructures.list_concat([1, 2], [3, 4]))}")
      IO.puts("[1,2,2,3]--[2]: #{inspect(DataStructures.list_subtract([1, 2, 2, 3], [2]))}")
      IO.puts("length   : #{DataStructures.list_length(list)}")
      IO.puts("3 in list: #{DataStructures.list_member?(list, 3)}")
      IO.puts("9 in list: #{DataStructures.list_member?(list, 9)}")

      assert DataStructures.list_integers() == [1, 2, 3, 4, 5]
      assert DataStructures.list_head([10, 20, 30]) == 10
      assert DataStructures.list_tail([10, 20, 30]) == [20, 30]
      assert DataStructures.list_concat([1], [2, 3]) == [1, 2, 3]
      assert DataStructures.list_subtract([1, 2, 2, 3], [2]) == [1, 2, 3]
      assert DataStructures.list_length(list) == 5
      assert DataStructures.list_member?(list, 3) == true
      assert DataStructures.list_member?(list, 9) == false
    end
  end

  describe "Maps" do
    test "atom-key map operations" do
      IO.puts("\n=== MAPS ===")
      m = DataStructures.map_atom_keys()
      IO.puts("map            : #{inspect(m)}")
      IO.puts("get :name      : #{DataStructures.map_get(m, :name)}")
      IO.puts("get :missing   : #{inspect(DataStructures.map_get(m, :missing))}")
      IO.puts("default :miss  : #{DataStructures.map_get_default(m, :missing, "N/A")}")
      updated = DataStructures.map_put(m, :score, 100)
      IO.puts("put :score 100 : #{inspect(updated)}")
      renamed = DataStructures.map_update_name(m, "Bob")
      IO.puts("update name    : #{inspect(renamed)}")
      deleted = DataStructures.map_delete(m, :age)
      IO.puts("delete :age    : #{inspect(deleted)}")

      assert DataStructures.map_get(m, :name) == "Alice"
      assert DataStructures.map_get(m, :age) == 30
      assert DataStructures.map_get(m, :missing) == nil
      assert DataStructures.map_get_default(m, :missing, "N/A") == "N/A"
      assert updated.score == 100
      assert renamed.name == "Bob"
      refute Map.has_key?(deleted, :age)
    end

    test "string-key map" do
      IO.puts("\n--- String-key map ---")
      m = DataStructures.map_string_keys()
      IO.puts("string map: #{inspect(m)}")
      IO.puts("name: #{m["name"]}")

      assert m["name"] == "Bob"
      assert m["age"] == 25
    end
  end

  describe "Keyword lists" do
    test "ordered option list" do
      IO.puts("\n=== KEYWORD LISTS ===")
      kw = DataStructures.keyword_list()
      IO.puts("keyword list : #{inspect(kw)}")
      IO.puts("host         : #{DataStructures.keyword_get(kw, :host)}")
      IO.puts("port         : #{DataStructures.keyword_get(kw, :port)}")
      IO.puts("missing key  : #{inspect(DataStructures.keyword_get(kw, :timeout))}")

      assert DataStructures.keyword_get(kw, :host) == "localhost"
      assert DataStructures.keyword_get(kw, :port) == 4000
      assert DataStructures.keyword_get(kw, :timeout) == nil
    end
  end

  describe "Structs — data class / value object replacement" do
    test "create, access, and update a struct" do
      IO.puts("\n=== STRUCTS ===")
      alice = DataStructures.create_person("Alice", 30)
      IO.puts("person   : #{inspect(alice)}")
      IO.puts("name     : #{alice.name}")
      IO.puts("age      : #{alice.age}")
      IO.puts("email    : #{alice.email}")
      older = DataStructures.birthday(alice)
      IO.puts("birthday : #{inspect(older)}")
      IO.puts("greeting : #{DataStructures.person_greeting(alice)}")
      IO.puts("is_struct: #{is_struct(alice, Person)}")

      assert alice.name == "Alice"
      assert alice.age == 30
      assert alice.email == "unknown@example.com"
      assert older.age == 31
      assert is_struct(alice, Person)
    end

    test "enforce_keys — struct requires :name" do
      IO.puts("\n--- @enforce_keys ---")

      assert_raise ArgumentError, fn ->
        struct!(Person, age: 25)
      end

      IO.puts("struct!(Person, age: 25) raises ArgumentError as expected")
    end
  end

  describe "Date and Time" do
    test "date creation and difference" do
      IO.puts("\n=== DATE ===")
      today = DataStructures.today()
      d1 = DataStructures.build_date(2024, 1, 1)
      d2 = DataStructures.build_date(2024, 12, 31)
      diff = DataStructures.date_diff(d2, d1)
      IO.puts("today      : #{today}")
      IO.puts("2024-01-01 : #{d1}")
      IO.puts("2024-12-31 : #{d2}")
      IO.puts("diff days  : #{diff}")

      assert %Date{} = today
      assert diff == 365
    end

    test "DateTime — current UTC moment" do
      IO.puts("\n=== DATETIME ===")
      now = DataStructures.now()
      IO.puts("now: #{now}")
      assert %DateTime{} = now
    end
  end
end

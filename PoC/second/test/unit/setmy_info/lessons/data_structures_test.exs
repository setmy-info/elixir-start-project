defmodule SetmyInfo.Lessons.DataStructuresTest do
  @moduledoc "Lesson: Elixir composite data structures."

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.DataStructures
  alias SetmyInfo.Lessons.DataStructures.Person

  describe "Tuples" do
    test "construction and element access" do
      IO.puts("\n=== TUPLES ===")
      IO.puts("tuple_pair   => #{inspect(DataStructures.tuple_pair())}")
      IO.puts("tuple_triple => #{inspect(DataStructures.tuple_triple())}")
      IO.puts("elem({:ok,42}, 1) => #{DataStructures.tuple_elem({:ok, 42}, 1)}")
      IO.puts("tuple_size({1,2,3}) => #{DataStructures.get_tuple_size({1, 2, 3})}")

      assert DataStructures.tuple_pair() == {:ok, 42}
      assert DataStructures.tuple_triple() == {:error, :not_found, "resource missing"}
      assert DataStructures.tuple_elem({:ok, 42}, 0) == :ok
      assert DataStructures.tuple_elem({:ok, 42}, 1) == 42
      assert DataStructures.get_tuple_size({1, 2, 3}) == 3
    end
  end

  describe "Lists" do
    test "construction, head/tail, concatenation" do
      IO.puts("\n=== LISTS ===")
      IO.puts("list_integers => #{inspect(DataStructures.list_integers())}")
      IO.puts("list_mixed    => #{inspect(DataStructures.list_mixed())}")
      IO.puts("prepend 0 to [1,2,3] => #{inspect(DataStructures.list_prepend(0, [1, 2, 3]))}")
      IO.puts("head([1,2,3]) => #{DataStructures.list_head([1, 2, 3])}")
      IO.puts("tail([1,2,3]) => #{inspect(DataStructures.list_tail([1, 2, 3]))}")

      assert DataStructures.list_integers() == [1, 2, 3, 4, 5]
      assert DataStructures.list_prepend(0, [1, 2, 3]) == [0, 1, 2, 3]
      assert DataStructures.list_head([1, 2, 3]) == 1
      assert DataStructures.list_tail([1, 2, 3]) == [2, 3]
      assert DataStructures.list_concat([1, 2], [3, 4]) == [1, 2, 3, 4]
      assert DataStructures.list_subtract([1, 2, 2, 3], [2]) == [1, 2, 3]
      assert DataStructures.list_length([1, 2, 3]) == 3
      assert DataStructures.list_member?([1, 2, 3], 2) == true
      refute DataStructures.list_member?([1, 2, 3], 9)
    end
  end

  describe "Maps" do
    test "construction, access, update, delete" do
      IO.puts("\n=== MAPS ===")
      m = DataStructures.map_atom_keys()
      IO.puts("map_atom_keys => #{inspect(m)}")
      IO.puts("map_get(:name) => #{DataStructures.map_get(m, :name)}")

      assert m == %{name: "Alice", age: 30, active: true}
      assert DataStructures.map_get(m, :name) == "Alice"
      assert DataStructures.map_get(m, :missing) == nil
      assert DataStructures.map_get_default(m, :missing, "default") == "default"
      assert DataStructures.map_put(m, :city, "Tallinn") |> Map.has_key?(:city)
      assert DataStructures.map_update_name(m, "Bob") == %{m | name: "Bob"}
      refute DataStructures.map_delete(m, :age) |> Map.has_key?(:age)
    end

    test "string-keyed maps use => syntax" do
      IO.puts("\n--- String-keyed maps ---")
      sm = DataStructures.map_string_keys()
      IO.puts("map_string_keys => #{inspect(sm)}")

      assert sm == %{"name" => "Bob", "age" => 25}
      assert sm["name"] == "Bob"
    end
  end

  describe "Keyword lists" do
    test "ordered list of atom-keyed pairs" do
      IO.puts("\n=== KEYWORD LISTS ===")
      kw = DataStructures.keyword_list()
      IO.puts("keyword_list => #{inspect(kw)}")
      IO.puts("port: #{DataStructures.keyword_get(kw, :port)}")

      assert DataStructures.keyword_get(kw, :host) == "localhost"
      assert DataStructures.keyword_get(kw, :port) == 4000
      assert DataStructures.keyword_get(kw, :debug) == true
      assert DataStructures.keyword_get(kw, :missing) == nil
    end
  end

  describe "Structs" do
    test "defstruct enforces shape at compile time" do
      IO.puts("\n=== STRUCTS ===")
      p = DataStructures.create_person("Alice", 30)
      IO.puts("create_person => #{inspect(p)}")
      IO.puts("person_greeting => #{DataStructures.person_greeting(p)}")

      assert p == %Person{name: "Alice", age: 30, email: "unknown@example.com"}
      assert DataStructures.person_greeting(p) == "Alice is 30 years old"
    end

    test "struct update syntax creates a new value — no mutation" do
      IO.puts("\n--- Struct update ---")
      p = DataStructures.create_person("Bob", 24)
      older = DataStructures.birthday(p)
      IO.puts("before: age=#{p.age}  after: age=#{older.age}")

      assert older.age == 25
      assert p.age == 24
    end
  end

  describe "Date and Time" do
    test "Date.new! and date arithmetic" do
      IO.puts("\n=== DATE / TIME ===")
      today = DataStructures.today()
      IO.puts("today => #{today}")

      d1 = DataStructures.build_date(2026, 6, 10)
      d2 = DataStructures.build_date(2026, 6, 1)
      IO.puts("date_diff(2026-06-10, 2026-06-01) => #{DataStructures.date_diff(d1, d2)}")

      assert %Date{} = today
      assert d1 == ~D[2026-06-10]
      assert DataStructures.date_diff(d1, d2) == 9
    end

    test "DateTime.utc_now returns a valid datetime" do
      now = DataStructures.now()
      IO.puts("now => #{now}")

      assert %DateTime{time_zone: "Etc/UTC"} = now
    end
  end
end

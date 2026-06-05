defmodule SetmyInfo.Lessons.DataStructures do
  @moduledoc """
  Demonstrates Elixir's composite data structures.

  ## Structures covered

  - **Tuple** — fixed-size, fast index access, heterogeneous
  - **List** — linked list, cheap prepend, O(n) random access
  - **Map** — hash map, O(1) average lookup and update
  - **Keyword list** — ordered `[{atom, value}]`, used for options
  - **Struct** — Elixir's data-class / value-object replacement
  - **Date / Time / DateTime** — standard calendar types
  """

  defmodule Person do
    @moduledoc """
    Struct example — Elixir's equivalent of a Java value object or a data class.

    `@enforce_keys` makes `:name` required at construction time.
    Default values can be provided inline in `defstruct`.
    Structs are just maps with a `__struct__` key and compile-time validation.
    """
    @enforce_keys [:name]
    defstruct [:name, age: 0, email: "unknown@example.com"]
  end

  # ──────────────────── Tuples ────────────────────────────────────────────────

  @doc "A pair — two-element tuple."
  def tuple_pair, do: {:ok, 42}

  @doc "A triple — three-element tuple."
  def tuple_triple, do: {:error, :not_found, "resource missing"}

  @doc "Access a tuple element by zero-based index."
  def tuple_elem(t, index), do: elem(t, index)

  @doc "Return the number of elements in a tuple."
  def get_tuple_size(t), do: tuple_size(t)

  # ──────────────────── Lists ─────────────────────────────────────────────────

  @doc "An integer list."
  def list_integers, do: [1, 2, 3, 4, 5]

  @doc "A mixed-type list — lists are heterogeneous."
  def list_mixed, do: [1, :atom, "string", true, nil]

  @doc "Prepend an element to a list using the cons `|` operator."
  def list_prepend(h, t), do: [h | t]

  @doc "Return the head (first element) of a list via pattern matching."
  def list_head([h | _]), do: h

  @doc "Return the tail (everything after the head) of a list."
  def list_tail([_ | t]), do: t

  @doc "Concatenate two lists."
  def list_concat(a, b), do: a ++ b

  @doc "Remove elements — `a -- b` removes first occurrence of each `b` element."
  def list_subtract(a, b), do: a -- b

  @doc "List length."
  def list_length(l), do: length(l)

  @doc "Check membership with `in`."
  def list_member?(l, v), do: v in l

  # ──────────────────── Maps ──────────────────────────────────────────────────

  @doc "A map with atom keys — access via `map.key` or `map[:key]`."
  def map_atom_keys, do: %{name: "Alice", age: 30, active: true}

  @doc "A map with string keys — must use `map[\"key\"]` syntax."
  def map_string_keys, do: %{"name" => "Bob", "age" => 25}

  @doc "Fetch a value by key (returns `nil` if missing)."
  def map_get(m, key), do: Map.get(m, key)

  @doc "Fetch with a fallback default value."
  def map_get_default(m, key, default), do: Map.get(m, key, default)

  @doc "Add or replace a key-value pair."
  def map_put(m, key, value), do: Map.put(m, key, value)

  @doc "Update syntax — requires the key to already exist; returns a new map."
  def map_update_name(m, new_name), do: %{m | name: new_name}

  @doc "Delete a key from a map."
  def map_delete(m, key), do: Map.delete(m, key)

  # ──────────────────── Keyword lists ─────────────────────────────────────────

  @doc "A keyword list — an ordered list of `{atom, value}` pairs used for options."
  def keyword_list, do: [host: "localhost", port: 4000, debug: true]

  @doc "Fetch the first value for a key."
  def keyword_get(kw, key), do: Keyword.get(kw, key)

  # ──────────────────── Structs ────────────────────────────────────────────────

  @doc "Create a `Person` struct — like a data class with named fields."
  def create_person(name, age), do: %Person{name: name, age: age}

  @doc "Structural update — returns a new struct with `age` incremented."
  def birthday(person), do: %{person | age: person.age + 1}

  @doc "Pattern-match a struct to extract fields."
  def person_greeting(%Person{name: name, age: age}), do: "#{name} is #{age} years old"

  # ──────────────────── Date & Time ───────────────────────────────────────────

  @doc "Today's UTC date."
  def today, do: Date.utc_today()

  @doc "Build a specific date — raises on invalid input."
  def build_date(year, month, day), do: Date.new!(year, month, day)

  @doc "Number of days between two dates (`d1 - d2`)."
  def date_diff(d1, d2), do: Date.diff(d1, d2)

  @doc "Current UTC date-time."
  def now, do: DateTime.utc_now()
end

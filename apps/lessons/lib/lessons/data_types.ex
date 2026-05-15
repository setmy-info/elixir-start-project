defmodule SetmyInfo.Lessons.DataTypes do
  @moduledoc """
  Demonstrates Elixir's core primitive data types.

  All values in Elixir are immutable. Re-binding a variable name creates a new binding,
  not an in-place mutation.

  ## Types covered

  - `boolean` — `true` / `false` (are atoms under the hood)
  - `integer` — arbitrary precision, supports 0b/0o/0x/_ separators
  - `float` — 64-bit IEEE 754
  - `atom` — named constant whose name is its value
  - `string` — UTF-8 binary
  - `charlist` — list of Unicode codepoints (Erlang-style)
  - `nil` — the absence of a value (also an atom)
  """

  @doc "Returns the boolean `true`."
  def boolean_true, do: true

  @doc "Returns the boolean `false`."
  def boolean_false, do: false

  @doc "Strict boolean AND — both operands must be booleans."
  def boolean_and(a, b), do: a and b

  @doc "Strict boolean OR."
  def boolean_or(a, b), do: a or b

  @doc "Boolean negation."
  def boolean_not(a), do: not a

  @doc "A positive integer literal."
  def integer_positive, do: 42

  @doc "A negative integer literal."
  def integer_negative, do: -17

  @doc "Float division — always returns a float."
  def integer_division(a, b), do: a / b

  @doc "Floor (integer) division."
  def integer_div(a, b), do: div(a, b)

  @doc "Remainder (modulo)."
  def integer_rem(a, b), do: rem(a, b)

  @doc "Integer from a binary literal `0b1010`."
  def binary_literal, do: 0b1010

  @doc "Integer from an octal literal `0o17`."
  def octal_literal, do: 0o17

  @doc "Integer from a hexadecimal literal `0xFF`."
  def hex_literal, do: 0xFF

  @doc "Float constant — 64-bit IEEE 754."
  def float_example, do: 3.14

  @doc "Float addition."
  def float_add(a, b), do: a + b

  @doc "Round a float to `decimals` decimal places."
  def float_round(f, decimals), do: Float.round(f, decimals)

  @doc "An atom — a named constant whose value is its own name."
  def atom_example, do: :hello

  @doc "Booleans are atoms in Elixir — `is_atom(true)` is `true`."
  def boolean_is_atom, do: is_atom(true)

  @doc "A UTF-8 string (Elixir binary)."
  def string_example, do: "Hello, Elixir!"

  @doc "String concatenation with `<>`."
  def string_concat(a, b), do: a <> b

  @doc "String interpolation with `\#{expr}`."
  def string_interpolate(name), do: "Hello, #{name}!"

  @doc "String length in Unicode codepoints."
  def string_length(s), do: String.length(s)

  @doc "Upcase a string."
  def string_upcase(s), do: String.upcase(s)

  @doc "Split a string on a delimiter."
  def string_split(s, delimiter), do: String.split(s, delimiter)

  @doc "Trim whitespace."
  def string_trim(s), do: String.trim(s)

  @doc "`nil` — the absence of a value (also an atom)."
  def nil_example, do: nil

  @doc "Check if a value is `nil`."
  def is_nil_check(v), do: is_nil(v)

  @doc "Unicode codepoint of a character via `?` prefix."
  def char_codepoint, do: ?A

  @doc "A charlist — list of Unicode codepoints, Erlang-style strings."
  def charlist_example, do: ~c"hello"

  @doc "Convert a string to a charlist."
  def to_charlist(s), do: String.to_charlist(s)

  @doc "Convert a charlist back to a string."
  def from_charlist(cl), do: List.to_string(cl)
end

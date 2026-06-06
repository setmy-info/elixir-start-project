defmodule SetmyInfo.Lessons.DataTypes do
  @moduledoc """
  Demonstrates Elixir's core primitive data types, variables, and constants.

  All values in Elixir are **immutable**. Re-binding a variable name creates a new
  binding in the current scope — it does not mutate the old value.

  ## Types covered

  - `boolean` — `true` / `false` (are atoms under the hood)
  - `integer` — arbitrary precision, supports 0b/0o/0x/_ separators
  - `float` — 64-bit IEEE 754
  - `atom` — named constant whose name is its value
  - `string` — UTF-8 binary
  - `charlist` — list of Unicode codepoints (Erlang-style)
  - `nil` — the absence of a value (also an atom)

  ## Variables

  Elixir variables are **dynamically typed** and **lexically scoped**. The `=` operator
  is the *match operator*, not assignment — it pattern-matches the right side against
  the left side and binds free variables.

  ```elixir
  x = 42          # binds x to 42
  x = "hello"     # rebinds x to "hello" (42 is untouched)
  ^x = "hello"    # pin: asserts x already equals "hello"; raises if not
  _unused = 99    # _ prefix silences the unused-variable compiler warning
  ```

  ## Constants (module attributes)

  Elixir has no `const` keyword. Module attributes (`@name value`) evaluated at
  compile time serve as constants. They are inlined at every call site and do not
  exist at runtime.

  ```elixir
  @pi 3.14159265358979
  def circle_area(r), do: @pi * r * r
  ```

  ## Atoms (extended)

  Atoms are interned: only one copy per unique name exists in the VM's global atom
  table (default limit: 1 048 576). Never create atoms dynamically from untrusted
  input — use `String.to_existing_atom/1` rather than `String.to_atom/1`.

  ```elixir
  :ok                            # simple atom
  :"hello world"                 # quoted atom — any string content
  Atom.to_string(:hello)         # => "hello"
  String.to_existing_atom("ok")  # safe — only if :ok already exists
  ```
  """

  @my_constant 42
  @pi 3.14159265358979
  @greeting "Hello"

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
  def nil?(v), do: is_nil(v)

  @doc "Unicode codepoint of a character via `?` prefix."
  def char_codepoint, do: ?A

  @doc "A charlist — list of Unicode codepoints, Erlang-style strings."
  def charlist_example, do: ~c"hello"

  @doc "Convert a string to a charlist."
  def to_charlist(s), do: String.to_charlist(s)

  @doc "Convert a charlist back to a string."
  def from_charlist(cl), do: List.to_string(cl)

  @doc """
  Demonstrates variable binding.

  `x = 42` binds the name `x` to the integer `42`. The `=` sign is the
  *match operator*, not assignment — it succeeds when the left side can be
  made equal to the right side by binding free variables.
  """
  def variable_binding do
    x = 42
    x
  end

  @doc """
  Demonstrates variable rebinding.

  Rebinding `x` to a new value does **not** mutate the old value — it creates a
  new binding in the current scope.
  """
  def variable_rebind do
    x = 1
    x = x + 1
    x
  end

  @doc """
  Demonstrates the pin operator `^`.

  `^x` in a pattern asserts that the variable already has that value — it does
  **not** rebind.
  """
  def variable_pin(expected) do
    value = expected

    case value do
      ^expected -> :matched
      _ -> :not_matched
    end
  end

  @doc """
  Demonstrates the `_` unused-variable prefix.

  Prefixing a variable with `_` tells the compiler the value is intentionally
  ignored, silencing the "variable is unused" warning.
  """
  def variable_unused do
    _ignored = "this value is never used"
    :ok
  end

  @doc """
  Returns the compile-time constant `@my_constant`.

  Module attributes annotated before a function are inlined at their use sites by
  the compiler. They exist **only** at compile time.
  """
  def constant_value, do: @my_constant

  @doc "Returns the `@pi` module-attribute constant."
  def pi_value, do: @pi

  @doc "Returns the `@greeting` string constant."
  def greeting_constant, do: @greeting

  @doc """
  Converts an atom to its string representation.
  """
  def atom_to_string_example, do: Atom.to_string(:hello)

  @doc """
  Converts a string to an **already-existing** atom.

  `String.to_existing_atom/1` is safe: it raises `ArgumentError` if the atom was
  never interned, preventing atom-table exhaustion from untrusted input.
  Never use `String.to_atom/1` with user-supplied strings.
  """
  def atom_from_existing_string, do: String.to_existing_atom("ok")

  @doc """
  Demonstrates a quoted atom — atoms whose names contain spaces or special chars.
  """
  def atom_quoted_example, do: :"hello world"

  @doc """
  Shows the three special atoms that double as reserved words: `true`, `false`, `nil`.
  """
  def atom_reserved_examples, do: {true, false, nil}

  @doc """
  Atoms are compared by identity (O(1)), not by content.
  """
  def atom_equality, do: :ok == :ok

  @doc """
  Returns the `:ok` and `:error` convention atoms.
  """
  def atom_ok_error, do: {:ok, :error}
end

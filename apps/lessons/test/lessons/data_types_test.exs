defmodule SetmyInfo.Lessons.DataTypesTest do
  @moduledoc """
  Lesson: Elixir Primitive Data Types.

  The test runner executes these as a learning environment — each test
  prints to stdout AND asserts the expected value.
  """

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.DataTypes

  describe "Booleans" do
    test "true and false are the only two boolean values" do
      IO.puts("\n=== BOOLEANS ===")
      IO.puts("true  value: #{DataTypes.boolean_true()}")
      IO.puts("false value: #{DataTypes.boolean_false()}")
      IO.puts("is_boolean(true)  => #{is_boolean(true)}")
      IO.puts("is_boolean(0)     => #{is_boolean(0)}")

      assert DataTypes.boolean_true() == true
      assert DataTypes.boolean_false() == false
      assert is_boolean(true)
      assert is_boolean(false)
      refute is_boolean(0)
      refute is_boolean(nil)
    end

    test "boolean operators: and, or, not" do
      IO.puts("\n--- Boolean operators ---")
      IO.puts("true and true  => #{DataTypes.boolean_and(true, true)}")
      IO.puts("true and false => #{DataTypes.boolean_and(true, false)}")
      IO.puts("false or true  => #{DataTypes.boolean_or(false, true)}")
      IO.puts("not true       => #{DataTypes.boolean_not(true)}")

      assert DataTypes.boolean_and(true, true) == true
      assert DataTypes.boolean_and(true, false) == false
      assert DataTypes.boolean_or(false, true) == true
      assert DataTypes.boolean_not(true) == false
    end
  end

  describe "Integers" do
    test "integer literals including binary, octal, and hex" do
      IO.puts("\n=== INTEGERS ===")
      IO.puts("42               => #{DataTypes.integer_positive()}")
      IO.puts("-17              => #{DataTypes.integer_negative()}")
      IO.puts("0b1010 (binary)  => #{DataTypes.binary_literal()}")
      IO.puts("0o17   (octal)   => #{DataTypes.octal_literal()}")
      IO.puts("0xFF   (hex)     => #{DataTypes.hex_literal()}")

      assert DataTypes.integer_positive() == 42
      assert DataTypes.integer_negative() == -17
      assert DataTypes.binary_literal() == 10
      assert DataTypes.octal_literal() == 15
      assert DataTypes.hex_literal() == 255
    end

    test "division: / returns float, div/2 returns integer" do
      IO.puts("\n--- Division ---")
      IO.puts("10 / 3      => #{DataTypes.integer_division(10, 3)}")
      IO.puts("div(10, 3)  => #{DataTypes.integer_div(10, 3)}")
      IO.puts("rem(10, 3)  => #{DataTypes.integer_rem(10, 3)}")

      assert DataTypes.integer_division(10, 3) == 10 / 3
      assert is_float(DataTypes.integer_division(10, 3))
      assert DataTypes.integer_div(10, 3) == 3
      assert DataTypes.integer_rem(10, 3) == 1
    end
  end

  describe "Floats" do
    test "float values and rounding" do
      IO.puts("\n=== FLOATS ===")
      IO.puts("3.14          => #{DataTypes.float_example()}")
      IO.puts("1.1 + 2.2     => #{DataTypes.float_add(1.1, 2.2)}")
      IO.puts("round(3.14159, 2) => #{DataTypes.float_round(3.14159, 2)}")

      assert DataTypes.float_example() == 3.14
      assert DataTypes.float_round(3.14159, 2) == 3.14
      assert is_float(DataTypes.float_example())
    end
  end

  describe "Atoms" do
    test "atoms are named constants" do
      IO.puts("\n=== ATOMS ===")
      IO.puts(":hello        => #{DataTypes.atom_example()}")
      IO.puts("is_atom(:ok)  => #{is_atom(:ok)}")
      IO.puts("is_atom(true) => #{DataTypes.boolean_is_atom()}")
      IO.puts("is_atom(nil)  => #{is_atom(nil)}")

      assert DataTypes.atom_example() == :hello
      assert is_atom(:ok)
      assert DataTypes.boolean_is_atom() == true
      assert is_atom(nil)
    end
  end

  describe "Strings" do
    test "string creation and common operations" do
      IO.puts("\n=== STRINGS ===")
      IO.puts("string example : #{DataTypes.string_example()}")
      IO.puts("concat         : #{DataTypes.string_concat("Hello, ", "World!")}")
      IO.puts("interpolate    : #{DataTypes.string_interpolate("Elixir")}")
      IO.puts("length(Hello)  : #{DataTypes.string_length("Hello")}")
      IO.puts("upcase(hello)  : #{DataTypes.string_upcase("hello")}")
      IO.puts("split(a,b,c)   : #{inspect(DataTypes.string_split("a,b,c", ","))}")
      IO.puts("trim(  hi  )   : '#{DataTypes.string_trim("  hi  ")}'")

      assert DataTypes.string_example() == "Hello, Elixir!"
      assert DataTypes.string_concat("foo", "bar") == "foobar"
      assert DataTypes.string_interpolate("World") == "Hello, World!"
      assert DataTypes.string_length("Hello") == 5
      assert DataTypes.string_upcase("hello") == "HELLO"
      assert DataTypes.string_split("a,b,c", ",") == ["a", "b", "c"]
      assert DataTypes.string_trim("  hi  ") == "hi"
    end
  end

  describe "Nil" do
    test "nil is the absence of a value" do
      IO.puts("\n=== NIL ===")
      IO.puts("nil           => #{inspect(DataTypes.nil_example())}")
      IO.puts("is_nil(nil)   => #{DataTypes.is_nil_check(nil)}")
      IO.puts("is_nil(false) => #{DataTypes.is_nil_check(false)}")
      IO.puts("is_nil(0)     => #{DataTypes.is_nil_check(0)}")
      IO.puts("is_atom(nil)  => #{is_atom(nil)}")

      assert DataTypes.nil_example() == nil
      assert DataTypes.is_nil_check(nil) == true
      assert DataTypes.is_nil_check(false) == false
      assert DataTypes.is_nil_check(0) == false
    end
  end

  describe "Character codes and charlists" do
    test "?A syntax returns the Unicode codepoint" do
      IO.puts("\n=== CHARACTER CODES ===")
      IO.puts("?A => #{DataTypes.char_codepoint()}")
      IO.puts("?a => #{?a}")
      IO.puts("?0 => #{?0}")

      assert DataTypes.char_codepoint() == 65
      assert ?a == 97
      assert ?0 == 48
    end

    test "charlists vs strings" do
      IO.puts("\n--- Charlists ---")
      cl = DataTypes.charlist_example()
      IO.puts("charlist ~c\"hello\" : #{inspect(cl)}")
      IO.puts("to_charlist(str)  : #{inspect(DataTypes.to_charlist("hi"))}")
      IO.puts("from_charlist     : #{DataTypes.from_charlist(~c"world")}")

      assert DataTypes.charlist_example() == ~c"hello"
      assert DataTypes.to_charlist("hi") == ~c"hi"
      assert DataTypes.from_charlist(~c"world") == "world"
    end
  end
end

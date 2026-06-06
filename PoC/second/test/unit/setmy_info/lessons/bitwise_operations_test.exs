defmodule SetmyInfo.Lessons.BitwiseOperationsTest do
  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.BitwiseOperations, as: Bits

  describe "Bitwise AND" do
    test "band keeps only bits set in both operands" do
      IO.puts("\n=== BITWISE AND ===")
      IO.puts("0b1100 &&& 0b1010 => #{inspect(Bits.band_op(0b1100, 0b1010), base: :binary)}")
      IO.puts("0xFF &&& 0x0F     => #{Bits.band_op(0xFF, 0x0F)}")

      assert Bits.band_op(0b1100, 0b1010) == 0b1000
      assert Bits.band_op(0xFF, 0x0F) == 0x0F
      assert Bits.band_op(5, 3) == 1
    end
  end

  describe "Bitwise OR" do
    test "bor sets a bit if present in either operand" do
      IO.puts("\n=== BITWISE OR ===")
      IO.puts("0b1100 ||| 0b1010 => #{inspect(Bits.bor_op(0b1100, 0b1010), base: :binary)}")
      IO.puts("0xF0 ||| 0x0F     => #{Bits.bor_op(0xF0, 0x0F)}")

      assert Bits.bor_op(0b1100, 0b1010) == 0b1110
      assert Bits.bor_op(0xF0, 0x0F) == 0xFF
      assert Bits.bor_op(5, 2) == 7
    end
  end

  describe "Bitwise XOR" do
    test "bxor sets a bit only when operands differ" do
      IO.puts("\n=== BITWISE XOR ===")
      IO.puts("0b1100 ^^^ 0b1010 => #{inspect(Bits.bxor_op(0b1100, 0b1010), base: :binary)}")
      IO.puts("0xFF ^^^ 0xFF     => #{Bits.bxor_op(0xFF, 0xFF)}")

      assert Bits.bxor_op(0b1100, 0b1010) == 0b0110
      assert Bits.bxor_op(0xFF, 0xFF) == 0x00
      assert Bits.bxor_op(5, 3) == 6
    end
  end

  describe "Bitwise NOT" do
    test "bnot flips all bits (one's complement)" do
      IO.puts("\n=== BITWISE NOT ===")
      IO.puts("~~~0  => #{Bits.bnot_op(0)}")
      IO.puts("~~~1  => #{Bits.bnot_op(1)}")
      IO.puts("~~~-1 => #{Bits.bnot_op(-1)}")

      assert Bits.bnot_op(0) == -1
      assert Bits.bnot_op(-1) == 0
      assert Bits.bnot_op(1) == -2
    end
  end

  describe "Bit shifts" do
    test "left shift multiplies by powers of two" do
      IO.puts("\n=== BIT SHIFTS ===")
      IO.puts("1 <<< 0  => #{Bits.shift_left(1, 0)}")
      IO.puts("1 <<< 4  => #{Bits.shift_left(1, 4)}")
      IO.puts("3 <<< 2  => #{Bits.shift_left(3, 2)}")

      assert Bits.shift_left(1, 0) == 1
      assert Bits.shift_left(1, 4) == 16
      assert Bits.shift_left(3, 2) == 12
    end

    test "right shift divides by powers of two" do
      IO.puts("16 >>> 1 => #{Bits.shift_right(16, 1)}")
      IO.puts("16 >>> 4 => #{Bits.shift_right(16, 4)}")
      IO.puts("7  >>> 1 => #{Bits.shift_right(7, 1)}")

      assert Bits.shift_right(16, 1) == 8
      assert Bits.shift_right(16, 4) == 1
      assert Bits.shift_right(7, 1) == 3
    end
  end

  describe "Bit inspection" do
    test "bit_set? checks a specific bit position" do
      IO.puts("\n=== BIT INSPECTION ===")
      IO.puts("bit_set?(0b1010, 1) => #{Bits.bit_set?(0b1010, 1)}")
      IO.puts("bit_set?(0b1010, 0) => #{Bits.bit_set?(0b1010, 0)}")

      assert Bits.bit_set?(0b1010, 1) == true
      assert Bits.bit_set?(0b1010, 0) == false
      assert Bits.bit_set?(0b1010, 3) == true
    end

    test "even? and odd? use the LSB trick" do
      IO.puts("even?(4) => #{Bits.even?(4)}")
      IO.puts("odd?(7)  => #{Bits.odd?(7)}")

      assert Bits.even?(4) == true
      assert Bits.even?(7) == false
      assert Bits.odd?(7) == true
      assert Bits.odd?(4) == false
    end
  end

  describe "Bit manipulation" do
    test "set_bit, clear_bit, toggle_bit" do
      IO.puts("\n=== BIT MANIPULATION ===")
      IO.puts("set_bit(0b1010, 0)    => #{inspect(Bits.set_bit(0b1010, 0), base: :binary)}")
      IO.puts("clear_bit(0b1010, 1)  => #{inspect(Bits.clear_bit(0b1010, 1), base: :binary)}")
      IO.puts("toggle_bit(0b1010, 0) => #{inspect(Bits.toggle_bit(0b1010, 0), base: :binary)}")

      assert Bits.set_bit(0b1010, 0) == 0b1011
      assert Bits.clear_bit(0b1010, 1) == 0b1000
      assert Bits.toggle_bit(0b1010, 0) == 0b1011
      assert Bits.toggle_bit(0b1011, 0) == 0b1010
    end

    test "bitmask builds a mask of n low bits" do
      IO.puts("\n=== BITMASKS ===")
      IO.puts("bitmask(4) => #{inspect(Bits.bitmask(4), base: :binary)}")
      IO.puts("bitmask(8) => 0x#{Integer.to_string(Bits.bitmask(8), 16)}")

      assert Bits.bitmask(4) == 0b1111
      assert Bits.bitmask(8) == 0xFF
      assert Bits.bitmask(0) == 0
    end

    test "extract_bits pulls a field out of a packed integer" do
      IO.puts("\n=== BIT EXTRACTION ===")
      # 0b11010110 — extract bits 2..4 (width 3, offset 2)
      n = 0b11010110
      IO.puts("extract_bits(0b11010110, offset=2, width=3) => #{Bits.extract_bits(n, 2, 3)}")

      assert Bits.extract_bits(0b11010110, 2, 3) == 0b101
    end

    test "popcount counts set bits" do
      IO.puts("\n=== POPCOUNT ===")
      IO.puts("popcount(0)    => #{Bits.popcount(0)}")
      IO.puts("popcount(0xFF) => #{Bits.popcount(0xFF)}")
      IO.puts("popcount(0b1010) => #{Bits.popcount(0b1010)}")

      assert Bits.popcount(0) == 0
      assert Bits.popcount(0xFF) == 8
      assert Bits.popcount(0b1010) == 2
      assert Bits.popcount(0b1111_1111) == 8
    end
  end
end

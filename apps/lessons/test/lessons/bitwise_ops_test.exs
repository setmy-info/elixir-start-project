defmodule SetmyInfo.Lessons.BitwiseOpsTest do
  @moduledoc """
  Lesson: Bitwise operators and binary/bitstring manipulation.

  Elixir inherits Erlang's full bitwise suite. Binary pattern-matching
  (the bitstring syntax) is unique to the BEAM and has no equivalent in
  most languages.
  """

  use ExUnit.Case, async: true

  alias SetmyInfo.Lessons.BitwiseOps

  describe "Bitwise AND &&&" do
    test "keeps only bits set in both operands" do
      IO.puts("\n=== BITWISE AND &&& ===")
      IO.puts("0b1100 &&& 0b1010 = #{Integer.to_string(BitwiseOps.bit_and(0b1100, 0b1010), 2)}")
      IO.puts("0xFF &&& 0x0F     = #{BitwiseOps.bit_and(0xFF, 0x0F)}")

      assert BitwiseOps.bit_and(0b1100, 0b1010) == 0b1000
      assert BitwiseOps.bit_and(0xFF, 0x0F) == 0x0F
      assert BitwiseOps.bit_and(0b1111, 0b0000) == 0
    end

    test "flag_set? checks whether a specific bit is 1" do
      IO.puts("\n--- Flag checking with AND ---")
      flags = 0b0101
      IO.puts("flags = 0b0101")
      IO.puts("bit 0 set? #{BitwiseOps.flag_set?(flags, 0b0001)}")
      IO.puts("bit 1 set? #{BitwiseOps.flag_set?(flags, 0b0010)}")
      IO.puts("bit 2 set? #{BitwiseOps.flag_set?(flags, 0b0100)}")

      assert BitwiseOps.flag_set?(0b0101, 0b0001) == true
      assert BitwiseOps.flag_set?(0b0101, 0b0010) == false
      assert BitwiseOps.flag_set?(0b0101, 0b0100) == true
    end
  end

  describe "Bitwise OR |||" do
    test "sets bits that are set in either operand" do
      IO.puts("\n=== BITWISE OR ||| ===")
      IO.puts("0b1100 ||| 0b1010 = #{Integer.to_string(BitwiseOps.bit_or(0b1100, 0b1010), 2)}")

      assert BitwiseOps.bit_or(0b1100, 0b1010) == 0b1110
      assert BitwiseOps.bit_or(0b0000, 0b1111) == 0b1111
    end

    test "set_flag turns on a specific bit" do
      IO.puts("\n--- Set flag with OR ---")
      value = 0b0000
      with_bit2 = BitwiseOps.set_flag(value, 0b0100)
      IO.puts("set bit 2: #{Integer.to_string(with_bit2, 2)}")

      assert BitwiseOps.set_flag(0b0001, 0b0100) == 0b0101
      assert BitwiseOps.set_flag(0b0101, 0b0100) == 0b0101
    end
  end

  describe "Bitwise XOR ^^^" do
    test "sets bits that differ between operands" do
      IO.puts("\n=== BITWISE XOR ^^^ ===")
      IO.puts("0b1100 ^^^ 0b1010 = #{Integer.to_string(BitwiseOps.bit_xor(0b1100, 0b1010), 2)}")

      assert BitwiseOps.bit_xor(0b1100, 0b1010) == 0b0110
      assert BitwiseOps.bit_xor(0xFF, 0xFF) == 0x00
    end

    test "toggle_flag flips a specific bit (XOR trick)" do
      IO.puts("\n--- Toggle flag with XOR ---")
      value = 0b0101
      toggled = BitwiseOps.toggle_flag(value, 0b0100)
      IO.puts("toggle bit 2 of 0b0101 => #{Integer.to_string(toggled, 2)}")

      assert BitwiseOps.toggle_flag(0b0101, 0b0100) == 0b0001
      assert BitwiseOps.toggle_flag(0b0001, 0b0100) == 0b0101
    end
  end

  describe "Bitwise NOT ~~~" do
    test "flips all bits (one's complement)" do
      IO.puts("\n=== BITWISE NOT ~~~ ===")
      IO.puts("~~~0  = #{BitwiseOps.bit_not(0)}")
      IO.puts("~~~1  = #{BitwiseOps.bit_not(1)}")
      IO.puts("~~~-1 = #{BitwiseOps.bit_not(-1)}")

      assert BitwiseOps.bit_not(0) == -1
      assert BitwiseOps.bit_not(-1) == 0
      assert BitwiseOps.bit_not(1) == -2
    end
  end

  describe "Bit shifts <<< and >>>" do
    test "left shift multiplies by powers of 2" do
      IO.puts("\n=== BIT SHIFTS ===")

      Enum.each(0..8, fn n ->
        IO.write("1 <<< #{n} = #{BitwiseOps.shift_left(1, n)}  ")
      end)

      IO.puts("")

      assert BitwiseOps.shift_left(1, 0) == 1
      assert BitwiseOps.shift_left(1, 3) == 8
      assert BitwiseOps.shift_left(1, 8) == 256
      assert BitwiseOps.shift_left(3, 4) == 48
    end

    test "right shift divides by powers of 2 (integer)" do
      IO.puts("\n--- Right shift ---")
      IO.puts("256 >>> 4 = #{BitwiseOps.shift_right(256, 4)}")
      IO.puts("17  >>> 1 = #{BitwiseOps.shift_right(17, 1)}")

      assert BitwiseOps.shift_right(256, 4) == 16
      assert BitwiseOps.shift_right(17, 1) == 8
      assert BitwiseOps.shift_right(1, 1) == 0
    end

    test "power_of_two? uses n &&& (n-1) == 0 trick" do
      IO.puts("\n--- Power-of-2 check ---")
      powers = Enum.filter(0..256, &BitwiseOps.power_of_two?/1)
      IO.puts("powers of 2 up to 256: #{inspect(powers)}")

      assert BitwiseOps.power_of_two?(1) == true
      assert BitwiseOps.power_of_two?(2) == true
      assert BitwiseOps.power_of_two?(128) == true
      assert BitwiseOps.power_of_two?(3) == false
      assert BitwiseOps.power_of_two?(0) == false
    end
  end

  describe "Practical bitwise examples" do
    test "RGB colour component extraction" do
      IO.puts("\n=== RGB COLOUR MANIPULATION ===")
      coral = 0xFF6B6B
      IO.puts("coral #FF6B6B => R=#{BitwiseOps.rgb_red(coral)} G=#{BitwiseOps.rgb_green(coral)} B=#{BitwiseOps.rgb_blue(coral)}")

      assert BitwiseOps.rgb_red(coral) == 0xFF
      assert BitwiseOps.rgb_green(coral) == 0x6B
      assert BitwiseOps.rgb_blue(coral) == 0x6B
    end

    test "RGB pack roundtrip" do
      r = 0xDE
      g = 0xAD
      b = 0xBE
      packed = BitwiseOps.rgb_pack(r, g, b)
      IO.puts("pack(0xDE, 0xAD, 0xBE) = 0x#{Integer.to_string(packed, 16)}")

      assert BitwiseOps.rgb_red(packed) == r
      assert BitwiseOps.rgb_green(packed) == g
      assert BitwiseOps.rgb_blue(packed) == b
    end

    test "next_power_of_two — buffer size rounding" do
      IO.puts("\n=== NEXT POWER OF 2 ===")

      Enum.each([1, 5, 100, 1000], fn n ->
        IO.puts("next_pow2(#{n}) = #{BitwiseOps.next_power_of_two(n)}")
      end)

      assert BitwiseOps.next_power_of_two(1) == 1
      assert BitwiseOps.next_power_of_two(5) == 8
      assert BitwiseOps.next_power_of_two(100) == 128
      assert BitwiseOps.next_power_of_two(1000) == 1024
    end

    test "popcount — count set bits" do
      IO.puts("\n=== POPCOUNT ===")

      Enum.each([0, 1, 7, 255], fn n ->
        IO.puts("popcount(#{n}) = #{BitwiseOps.popcount(n)}")
      end)

      assert BitwiseOps.popcount(0) == 0
      assert BitwiseOps.popcount(1) == 1
      assert BitwiseOps.popcount(0b0111) == 3
      assert BitwiseOps.popcount(0xFF) == 8
    end
  end

  describe "Binary / bitstring pattern matching" do
    test "parse and pack a 4-byte IPv4 address" do
      IO.puts("\n=== BINARY PATTERN MATCHING ===")
      binary = <<192, 168, 1, 100>>
      ip = BitwiseOps.parse_ipv4(binary)
      IO.puts("<<192, 168, 1, 100>> => #{inspect(ip)}")
      packed = BitwiseOps.pack_ipv4(ip)
      IO.puts("pack back => #{inspect(packed)}")

      assert ip == {192, 168, 1, 100}
      assert packed == binary
    end

    test "decode little-endian 32-bit integer from binary" do
      IO.puts("\n--- Endianness ---")
      little_endian = <<1, 0, 0, 0>>
      IO.puts("<<1, 0, 0, 0>> LE uint32 = #{BitwiseOps.decode_uint32_le(little_endian)}")
      assert BitwiseOps.decode_uint32_le(little_endian) == 1

      big = <<0, 0, 0, 255>>
      IO.puts("<<0, 0, 0, 255>> LE uint32 = #{BitwiseOps.decode_uint32_le(big)}")
      assert BitwiseOps.decode_uint32_le(big) == 0xFF000000
    end

    test "encode big-endian 32-bit integer to binary" do
      IO.puts("\n--- Big-endian encoding ---")
      binary = BitwiseOps.encode_uint32_be(256)
      IO.puts("encode_uint32_be(256) = #{inspect(binary)}")
      assert binary == <<0, 0, 1, 0>>
    end

    test "to_byte_list and from_byte_list roundtrip" do
      IO.puts("\n--- Binary ↔ byte list ---")
      original = "Hi!"
      bytes = BitwiseOps.to_byte_list(original)
      IO.puts("\"Hi!\" bytes: #{inspect(bytes)}")
      reconstructed = BitwiseOps.from_byte_list(bytes)
      IO.puts("reconstructed: #{reconstructed}")

      assert bytes == [72, 105, 33]
      assert reconstructed == original
    end

    test "xor_cipher is symmetric (encrypt twice = original)" do
      IO.puts("\n--- XOR cipher ---")
      plaintext = "secret"
      key = 0x42
      ciphertext = BitwiseOps.xor_cipher(plaintext, key)
      decrypted = BitwiseOps.xor_cipher(ciphertext, key)
      IO.puts("plaintext  : #{inspect(plaintext)}")
      IO.puts("key        : 0x#{Integer.to_string(key, 16)}")
      IO.puts("ciphertext : #{inspect(ciphertext)}")
      IO.puts("decrypted  : #{decrypted}")

      assert decrypted == plaintext
      assert ciphertext != plaintext
    end
  end
end

defmodule SetmyInfo.Lessons.BitwiseOps do
  @moduledoc """
  Demonstrates Elixir's bitwise and binary operators.

  Elixir inherits the full suite of Erlang's bitwise operations via the
  `Bitwise` module (included in the standard library). Binary data is
  handled as Erlang binaries using pattern-matching bitstring syntax.

  ## Operators (require `use Bitwise` or `import Bitwise`)

  | Operator | Meaning | Example |
  |---|---|---|
  | `band/2` or `&&&` | bitwise AND | `0b1100 &&& 0b1010 == 0b1000` |
  | `bor/2` or `\|\|\|` | bitwise OR | `0b1100 \|\|\| 0b1010 == 0b1110` |
  | `bxor/2` or `^^^` | bitwise XOR | `0b1100 ^^^ 0b1010 == 0b0110` |
  | `bnot/1` or `~~~` | bitwise NOT | `~~~0 == -1` |
  | `bsl/2` or `<<<` | bit shift left | `1 <<< 3 == 8` |
  | `bsr/2` or `>>>` | bit shift right | `16 >>> 2 == 4` |

  ## Binary / bitstring pattern matching

  Elixir lets you match raw bits and bytes directly in function heads and
  `case` expressions — a powerful feature with no equivalent in most languages.
  """

  import Bitwise

  # ──────────────────── Bitwise AND ────────────────────────────────────────────

  @doc "Bitwise AND — bits set in BOTH operands."
  def bit_and(a, b), do: a &&& b

  @doc "Check if a flag is set using AND mask."
  def flag_set?(value, flag), do: (value &&& flag) != 0

  # ──────────────────── Bitwise OR ─────────────────────────────────────────────

  @doc "Bitwise OR — bits set in EITHER operand."
  def bit_or(a, b), do: a ||| b

  @doc "Set a flag bit."
  def set_flag(value, flag), do: value ||| flag

  # ──────────────────── Bitwise XOR ────────────────────────────────────────────

  @doc "Bitwise XOR — bits set in ONE operand but not both."
  def bit_xor(a, b), do: bxor(a, b)

  @doc "Toggle (flip) a flag bit using XOR."
  def toggle_flag(value, flag), do: bxor(value, flag)

  # ──────────────────── Bitwise NOT ────────────────────────────────────────────

  @doc "Bitwise NOT — flip all bits (one's complement)."
  def bit_not(a), do: bnot(a)

  # ──────────────────── Bit shifts ─────────────────────────────────────────────

  @doc "Left shift — equivalent to multiplying by 2^n."
  def shift_left(a, n), do: a <<< n

  @doc "Right shift — equivalent to integer division by 2^n."
  def shift_right(a, n), do: a >>> n

  @doc "Check if a number is a power of 2 using bit trick."
  def power_of_two?(n) when n > 0, do: (n &&& n - 1) == 0
  def power_of_two?(_), do: false

  # ──────────────────── Practical examples ─────────────────────────────────────

  @doc "Extract the red component from an RGB colour encoded as 0xRRGGBB."
  def rgb_red(colour), do: colour >>> 16 &&& 0xFF

  @doc "Extract the green component."
  def rgb_green(colour), do: colour >>> 8 &&& 0xFF

  @doc "Extract the blue component."
  def rgb_blue(colour), do: colour &&& 0xFF

  @doc "Pack red/green/blue bytes into a single 0xRRGGBB integer."
  def rgb_pack(r, g, b), do: r <<< 16 ||| g <<< 8 ||| b

  @doc "Round up to next power of 2 (useful for buffer allocation)."
  def next_power_of_two(n) when n <= 1, do: 1

  def next_power_of_two(n) do
    n = n - 1
    n = n ||| n >>> 1
    n = n ||| n >>> 2
    n = n ||| n >>> 4
    n = n ||| n >>> 8
    n = n ||| n >>> 16
    n + 1
  end

  # ──────────────────── Binary / bitstring pattern matching ────────────────────

  @doc """
  Parse a 4-byte IPv4 address from a binary.
  Returns `{a, b, c, d}` — same format as Erlang's `:inet.parse_address/1`.
  """
  def parse_ipv4(<<a, b, c, d>>) when byte_size(<<a, b, c, d>>) == 4 do
    {a, b, c, d}
  end

  @doc "Pack an IPv4 tuple back to a 4-byte binary."
  def pack_ipv4({a, b, c, d}), do: <<a, b, c, d>>

  @doc "Decode a little-endian 32-bit unsigned integer from a binary."
  def decode_uint32_le(<<val::little-unsigned-integer-size(32)>>), do: val

  @doc "Encode a 32-bit unsigned integer as a big-endian binary."
  def encode_uint32_be(val) when is_integer(val) and val >= 0,
    do: <<val::big-unsigned-integer-size(32)>>

  @doc """
  Extract bytes from a binary using bitstring comprehension.
  Returns a list of integer byte values.
  """
  def to_byte_list(binary) when is_binary(binary) do
    for <<byte <- binary>>, do: byte
  end

  @doc "Build a binary from a list of byte integers."
  def from_byte_list(bytes) when is_list(bytes) do
    :erlang.list_to_binary(bytes)
  end

  @doc """
  XOR-cipher — encrypt / decrypt a binary with a single-byte key.
  (Symmetric: encrypt twice with the same key gives original.)
  """
  def xor_cipher(binary, key) when is_binary(binary) and is_integer(key) do
    for <<byte <- binary>>, into: <<>>, do: <<bxor(byte, key)>>
  end

  @doc "Count the number of set bits (popcount) in an integer."
  def popcount(0), do: 0
  def popcount(n) when n > 0, do: (n &&& 1) + popcount(n >>> 1)
end

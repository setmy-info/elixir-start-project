defmodule SetmyInfo.Lessons.BitwiseOperations do
  @moduledoc """
  Lesson: Elixir bitwise operations.

  Elixir exposes Erlang's integer bitwise operations through the `Bitwise`
  module.  Import it to use both the named functions (`band`, `bor`, `bxor`,
  `bnot`, `bsl`, `bsr`) and the shorthand operators (`&&&`, `|||`, `<<<`, `>>>`).

  All operations work on arbitrary-precision integers — no overflow.

  ## Java → Elixir mapping

  | Java      | Elixir operator | Elixir function |
  |-----------|-----------------|-----------------|
  | `a & b`   | `a &&& b`       | `band(a, b)`    |
  | `a \| b`  | `a \|\|\| b`    | `bor(a, b)`     |
  | `a ^ b`   | `a ^^^ b`       | `bxor(a, b)`    |
  | `~a`      | `bnot(a)`       | `bnot(a)`       |
  | `a << n`  | `a <<< n`       | `bsl(a, n)`     |
  | `a >> n`  | `a >>> n`       | `bsr(a, n)`     |
  """

  import Bitwise

  @doc "Bitwise AND: keep only bits set in both operands."
  @spec band_op(integer(), integer()) :: integer()
  def band_op(a, b), do: a &&& b

  @doc "Bitwise OR: set a bit if it is set in either operand."
  @spec bor_op(integer(), integer()) :: integer()
  def bor_op(a, b), do: a ||| b

  @doc "Bitwise XOR: set a bit if it differs between the two operands."
  @spec bxor_op(integer(), integer()) :: integer()
  def bxor_op(a, b), do: bxor(a, b)

  @doc "Bitwise NOT (one's complement)."
  @spec bnot_op(integer()) :: integer()
  def bnot_op(n), do: bnot(n)

  @doc "Shift `n` left by `bits` positions — equivalent to `n * 2^bits`."
  @spec shift_left(integer(), non_neg_integer()) :: integer()
  def shift_left(n, bits), do: n <<< bits

  @doc "Shift `n` right by `bits` positions — equivalent to `div(n, 2^bits)`."
  @spec shift_right(integer(), non_neg_integer()) :: integer()
  def shift_right(n, bits), do: n >>> bits

  @doc "True if bit at zero-indexed position `pos` (from LSB) is set."
  @spec bit_set?(integer(), non_neg_integer()) :: boolean()
  def bit_set?(n, pos), do: (n &&& 1 <<< pos) != 0

  @doc "True if `n` is even — same as checking the least-significant bit."
  @spec even?(integer()) :: boolean()
  def even?(n), do: (n &&& 1) == 0

  @doc "True if `n` is odd — same as checking the least-significant bit."
  @spec odd?(integer()) :: boolean()
  def odd?(n), do: (n &&& 1) == 1

  @doc "Count the number of set bits (Hamming weight / popcount)."
  @spec popcount(non_neg_integer()) :: non_neg_integer()
  def popcount(0), do: 0
  def popcount(n) when n > 0, do: (n &&& 1) + popcount(n >>> 1)

  @doc "Return a bitmask with the lowest `n` bits set."
  @spec bitmask(non_neg_integer()) :: non_neg_integer()
  def bitmask(n), do: (1 <<< n) - 1

  @doc "Extract `width` bits from `n` starting at bit offset `offset`."
  @spec extract_bits(integer(), non_neg_integer(), pos_integer()) :: integer()
  def extract_bits(n, offset, width), do: n >>> offset &&& bitmask(width)

  @doc "Set a single bit at position `pos` in `n`."
  @spec set_bit(integer(), non_neg_integer()) :: integer()
  def set_bit(n, pos), do: n ||| 1 <<< pos

  @doc "Clear (unset) a single bit at position `pos` in `n`."
  @spec clear_bit(integer(), non_neg_integer()) :: integer()
  def clear_bit(n, pos), do: n &&& bnot(1 <<< pos)

  @doc "Toggle a single bit at position `pos` in `n`."
  @spec toggle_bit(integer(), non_neg_integer()) :: integer()
  def toggle_bit(n, pos), do: bxor(n, 1 <<< pos)
end

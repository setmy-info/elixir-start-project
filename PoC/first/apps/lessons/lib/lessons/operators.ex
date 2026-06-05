defmodule SetmyInfo.Lessons.Operators do
  @moduledoc """
  Demonstrates Elixir's operator families.

  ## Categories

  - **Arithmetic** — `+`, `-`, `*`, `/`, `div/2`, `rem/2`, `:math.pow/2`
  - **Comparison** — `==`, `!=`, `<`, `>`, `<=`, `>=`, `===`, `!==`
  - **Logical (strict)** — `and`, `or`, `not` — require boolean operands
  - **Logical (truthy)** — `&&`, `||`, `!` — work with any value
  - **String** — `<>` concatenation
  - **List** — `++` concat, `--` difference
  - **Pattern match** — `=` is not assignment; it is structural matching
  - **Pipe** — `|>` passes the left-hand value as the first argument to the right
  """

  # ──────────────────── Arithmetic ────────────────────────────────────────────

  @doc "Addition."
  def add(a, b), do: a + b

  @doc "Subtraction."
  def subtract(a, b), do: a - b

  @doc "Multiplication."
  def multiply(a, b), do: a * b

  @doc "Float division — always returns a float."
  def divide(a, b), do: a / b

  @doc "Floor (integer) division."
  def floor_div(a, b), do: div(a, b)

  @doc "Remainder (modulo)."
  def remainder(a, b), do: rem(a, b)

  @doc "Exponentiation via `:math.pow/2` (returns float)."
  def power(base, exp), do: :math.pow(base, exp)

  # ──────────────────── Comparison ────────────────────────────────────────────

  @doc "Structural equality — `1 == 1.0` is `true`."
  def equal?(a, b), do: a == b

  @doc "Strict equality — `1 === 1.0` is `false` (type-aware)."
  def strict_equal?(a, b), do: a === b

  @doc "Structural inequality."
  def not_equal?(a, b), do: a != b

  @doc "Less than."
  def less_than?(a, b), do: a < b

  @doc "Greater than."
  def greater_than?(a, b), do: a > b

  @doc "Less than or equal."
  def lte?(a, b), do: a <= b

  @doc "Greater than or equal."
  def gte?(a, b), do: a >= b

  # ──────────────────── Logical (strict) ──────────────────────────────────────

  @doc "Strict `and` — both operands must be booleans."
  def logical_and(a, b), do: a and b

  @doc "Strict `or` — both operands must be booleans."
  def logical_or(a, b), do: a or b

  @doc "Strict `not` — operand must be a boolean."
  def logical_not(a), do: not a

  # ──────────────────── Logical (truthy) ──────────────────────────────────────

  @doc "Truthy `&&` — returns left if falsy, right otherwise."
  def truthy_and(a, b), do: a && b

  @doc "Truthy `||` — returns left if truthy, right otherwise."
  def truthy_or(a, b), do: a || b

  @doc "Truthy `!` — negates any truthy/falsy value."
  def truthy_not(a), do: !a

  # ──────────────────── String & list operators ────────────────────────────────

  @doc "String concatenation with `<>`."
  def concat(a, b), do: a <> b

  @doc "List concatenation with `++`."
  def list_concat(a, b), do: a ++ b

  @doc "List difference with `--` — removes first occurrence of each element."
  def list_diff(a, b), do: a -- b

  # ──────────────────── Pattern match ─────────────────────────────────────────

  @doc """
  `=` is the match operator — it binds variables on the left to values on the right.
  Returns the right-hand side, which is why `x = y = 5` works.
  """
  def match_tuple do
    {status, value} = {:ok, 42}
    {status, value}
  end

  # ──────────────────── Pipe operator ─────────────────────────────────────────

  @doc """
  `|>` passes the result of the left expression as the **first argument** to the right.

  Equivalent to: `String.upcase(String.pad_leading(Integer.to_string(n), 5, "0"))`
  """
  def pipe_example(n) do
    n
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.upcase()
  end
end

defmodule SetmyInfo.Lessons.FlowControl do
  @moduledoc """
  Demonstrates Elixir's flow control constructs.

  ## Key differences from imperative languages

  - **No `while` / `do-while`** — use tail recursion or `Enum` functions instead.
  - **`cond`** is the multi-branch equivalent of `if / elsif / else`.
  - **`case`** pattern-matches a value (like `switch` but structural).
  - **`with`** chains happy-path operations, short-circuiting on the first mismatch.
  - **`for`** is a list comprehension, not an imperative loop.
  """

  @doc """
  `if/else` — returns `:even` or `:odd`.

      iex> SetmyInfo.Lessons.FlowControl.even_or_odd(4)
      :even
  """
  def even_or_odd(n) do
    if rem(n, 2) == 0 do
      :even
    else
      :odd
    end
  end

  @doc """
  `unless` — runs the body when condition is `false`.

      iex> SetmyInfo.Lessons.FlowControl.unless_example(false)
      "Please log in"
  """
  def unless_example(logged_in) do
    unless logged_in do
      "Please log in"
    else
      "Welcome!"
    end
  end

  @doc """
  `cond` — Elixir's equivalent of `if / elsif / else` chains.
  The first clause that evaluates to truthy wins.

      iex> SetmyInfo.Lessons.FlowControl.grade(92)
      "A"
  """
  def grade(score) do
    cond do
      score >= 90 -> "A"
      score >= 80 -> "B"
      score >= 70 -> "C"
      score >= 60 -> "D"
      true -> "F"
    end
  end

  @doc """
  `case` — structural pattern match on a single value.

      iex> SetmyInfo.Lessons.FlowControl.describe_http(200)
      "OK"
  """
  def describe_http(code) do
    case code do
      200 -> "OK"
      201 -> "Created"
      404 -> "Not Found"
      500 -> "Server Error"
      _ -> "Unknown: #{code}"
    end
  end

  @doc """
  `case` with guards — guards refine pattern clauses.

      iex> SetmyInfo.Lessons.FlowControl.number_sign(0)
      :zero
  """
  def number_sign(n) do
    case n do
      x when x < 0 -> :negative
      0 -> :zero
      x when x > 0 -> :positive
    end
  end

  @doc """
  `with` — chains pattern-matching steps; stops at first mismatch.
  Equivalent to nested `case` but reads linearly.

      iex> SetmyInfo.Lessons.FlowControl.safe_divide(10, 2)
      {:ok, 5.0}

      iex> SetmyInfo.Lessons.FlowControl.safe_divide(10, 0)
      {:error, :division_by_zero}
  """
  def safe_divide(a, b) do
    with true <- b != 0,
         result <- a / b do
      {:ok, result}
    else
      false -> {:error, :division_by_zero}
    end
  end

  @doc """
  `for` comprehension — generate and collect a list.
  Not an imperative loop; it is a functional expression.

      iex> SetmyInfo.Lessons.FlowControl.squares(5)
      [1, 4, 9, 16, 25]
  """
  def squares(n), do: for(x <- 1..n, do: x * x)

  @doc """
  `for` with a filter guard — the comma-separated condition acts as a filter.

      iex> SetmyInfo.Lessons.FlowControl.even_squares(6)
      [4, 16, 36]
  """
  def even_squares(n), do: for(x <- 1..n, rem(x, 2) == 0, do: x * x)

  @doc """
  `for` with multiple generators — produces the Cartesian product.

      iex> SetmyInfo.Lessons.FlowControl.pairs([1, 2], [:a, :b])
      [{1, :a}, {1, :b}, {2, :a}, {2, :b}]
  """
  def pairs(list_a, list_b), do: for(a <- list_a, b <- list_b, do: {a, b})

  @doc """
  Tail recursion as a while-loop substitute: sum 1..n.
  Elixir optimises tail calls — no stack overflow for any n.

      iex> SetmyInfo.Lessons.FlowControl.sum_to(10)
      55
  """
  def sum_to(0), do: 0
  def sum_to(n) when n > 0, do: n + sum_to(n - 1)

  @doc """
  Tail-recursive countdown — models `while (n > 0) { ... }`.
  The accumulator replaces mutable state.

      iex> SetmyInfo.Lessons.FlowControl.countdown(5)
      [5, 4, 3, 2, 1]
  """
  def countdown(n, acc \\ [])
  def countdown(0, acc), do: Enum.reverse(acc)
  def countdown(n, acc) when n > 0, do: countdown(n - 1, [n | acc])
end

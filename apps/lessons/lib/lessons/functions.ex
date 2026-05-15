defmodule SetmyInfo.Lessons.Functions do
  @moduledoc """
  Demonstrates Elixir's function model.

  ## Key concepts

  - **Named functions** — defined with `def`/`defp`, belong to a module
  - **Multi-clause functions** — dispatch by pattern and guard
  - **Default parameters** — `param \\\\ default`
  - **Anonymous functions** — `fn args -> body end`, called with `.`
  - **Captured functions** — `&Module.function/arity` or `&(&1 + 1)` shorthand
  - **Higher-order functions** — functions that accept or return functions
  - **Closures** — anonymous functions capture variables from their scope
  """

  @doc "A simple named function."
  def greet(name), do: "Hello, #{name}!"

  @doc """
  Multi-clause function — Elixir picks the first matching clause top-to-bottom.
  This is Elixir's equivalent of overloaded methods.
  """
  def describe(0), do: "zero"
  def describe(1), do: "one"
  def describe(n) when n < 0, do: "negative"
  def describe(_), do: "many"

  @doc "Default parameter value with `\\\\`."
  def greet_with_title(name, title \\ "Mr/Ms"), do: "Hello, #{title} #{name}!"

  @doc """
  Returns an anonymous function (lambda / closure).
  The returned function captures `n` from its enclosing scope.
  """
  def make_adder(n) do
    fn x -> x + n end
  end

  @doc "Returns an anonymous function that doubles its argument."
  def make_doubler do
    fn x -> x * 2 end
  end

  @doc "Apply a unary function to a value — demonstrates passing functions as arguments."
  def apply_fn(f, value), do: f.(value)

  @doc "Apply a binary function to two values."
  def apply_fn2(f, a, b), do: f.(a, b)

  @doc "Higher-order map — transforms every element via `f`."
  def map_over(list, f), do: Enum.map(list, f)

  @doc "Higher-order filter — keeps elements for which `predicate` returns truthy."
  def keep_if(list, predicate), do: Enum.filter(list, predicate)

  @doc """
  Closure factory — returns a function that multiplies by `factor`.
  Each call to `multiplier/1` produces an independent closure.
  """
  def multiplier(factor) do
    fn n -> n * factor end
  end

  @doc """
  Function composition — returns `f(g(x))`.
  Equivalent to mathematical `(f ∘ g)(x)`.
  """
  def compose(f, g) do
    fn x -> f.(g.(x)) end
  end

  @doc "Captured function reference — `&String.length/1` as a value."
  def string_lengths(list), do: Enum.map(list, &String.length/1)

  @doc "Capture shorthand — `&(&1 * 2)` is `fn x -> x * 2 end`."
  def double_all(list), do: Enum.map(list, &(&1 * 2))

  @doc "Recursive factorial — naive, for illustration."
  def factorial(0), do: 1
  def factorial(n) when n > 0, do: n * factorial(n - 1)

  @doc "Tail-recursive factorial — O(1) stack depth, safe for large `n`."
  def factorial_tail(n, acc \\ 1)
  def factorial_tail(0, acc), do: acc
  def factorial_tail(n, acc) when n > 0, do: factorial_tail(n - 1, n * acc)
end

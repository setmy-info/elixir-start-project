defmodule Math.MathService do
  @moduledoc """
  Core arithmetic operations used by the CLI, REST, and GraphQL interfaces.

  ## Examples

      iex> Math.MathService.add(2, 3)
      5

      iex> Math.MathService.add(-4, 6)
      2
  """

  @doc """
  Adds two integers and returns the result.
  """
  def add(a, b) when is_integer(a) and is_integer(b) do
    a + b
  end
end

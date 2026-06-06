defmodule SetmyInfo.Math.MathService do
  @moduledoc """
  Core arithmetic operations used by the CLI, REST, and GraphQL interfaces.

  ## Examples

      iex> SetmyInfo.Math.MathService.add(2, 3)
      5

      iex> SetmyInfo.Math.MathService.add(-4, 6)
      2

  ## TODO

  `MathService` is a Java-ism. Because the `Math` library is intended for
  extraction into its own Hex package, the correct Elixir shape is to collapse
  this sub-module into the root library module:

      # lib/math.ex
      defmodule Math do
        def add(a, b), do: ...
      end

  Callers then use `Math.add/2` directly with no alias needed.
  Tracked in comparision.md — "Structure gap #1".
  """

  @type operand :: integer()

  @doc """
  Adds two integers and returns the result.
  """
  @spec add(operand(), operand()) :: operand()
  def add(a, b) when is_integer(a) and is_integer(b) do
    a + b
  end
end

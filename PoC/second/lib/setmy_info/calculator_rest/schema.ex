defmodule SetmyInfo.CalculatorRest.Schema do
  use Absinthe.Schema

  @moduledoc """
  GraphQL schema exposed by the shared HTTP server.

  The schema currently provides a single `add` query that delegates to the
  shared `SetmyInfo.Math.MathService`.
  """

  alias SetmyInfo.Math.MathService

  query do
    @desc "Adds two integers and returns the result."
    field :add, non_null(:integer) do
      arg(:a, non_null(:integer))
      arg(:b, non_null(:integer))

      resolve(fn %{a: a, b: b}, _resolution ->
        {:ok, MathService.add(a, b)}
      end)
    end
  end
end

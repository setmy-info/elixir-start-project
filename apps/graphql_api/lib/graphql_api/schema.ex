defmodule SetmyInfo.GraphqlApi.Schema do
  @moduledoc """
  Absinthe GraphQL schema.

  Exposes:
    query { add(a: Int!, b: Int!): Int }

  Example query:
    { add(a: 2, b: 3) }   # => { "data": { "add": 5 } }
  """

  use Absinthe.Schema

  query do
    @desc "Adds two integers. Delegates to SetmyInfo.RuntimeEngine for execution."
    field :add, :integer do
      arg(:a, non_null(:integer))
      arg(:b, non_null(:integer))

      resolve(fn %{a: a, b: b}, _ ->
        SetmyInfo.RuntimeEngine.Executor.run_and_release(:math_module, :add, [a, b])
      end)
    end

    @desc "Multiplies two integers."
    field :multiply, :integer do
      arg(:a, non_null(:integer))
      arg(:b, non_null(:integer))

      resolve(fn %{a: a, b: b}, _ ->
        SetmyInfo.RuntimeEngine.Executor.run_and_release(:math_module, :multiply, [a, b])
      end)
    end
  end
end

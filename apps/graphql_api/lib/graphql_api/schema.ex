defmodule SetmyInfo.GraphqlApi.Schema do
  @moduledoc """
  Absinthe GraphQL schema.

  Queries:
    { add(a: Int!, b: Int!): Int }
    { multiply(a: Int!, b: Int!): Int }
    { persons: [Person] }

  Mutations:
    mutation { createPerson(firstName: String!, lastName: String!): Person }
  """

  use Absinthe.Schema

  object :person do
    field(:id, :id)
    field(:first_name, :string)
    field(:last_name, :string)
  end

  query do
    @desc "Adds two integers."
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

    @desc "Returns all persons stored in the database."
    field :persons, list_of(:person) do
      resolve(fn _, _ ->
        {:ok, SetmyInfo.CoreLogic.Persons.list_persons()}
      end)
    end
  end

  mutation do
    @desc "Inserts a new person and returns the saved record."
    field :create_person, :person do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))

      resolve(fn %{first_name: first_name, last_name: last_name}, _ ->
        SetmyInfo.CoreLogic.Persons.create_person(%{
          first_name: first_name,
          last_name: last_name
        })
      end)
    end
  end
end

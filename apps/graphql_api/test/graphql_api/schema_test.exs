defmodule SetmyInfo.GraphqlApi.SchemaTest do
  use ExUnit.Case

  @add_query """
  { add(a: 2, b: 3) }
  """

  @multiply_query """
  { multiply(a: 3, b: 4) }
  """

  test "add query returns correct result" do
    assert {:ok, %{data: %{"add" => 5}}} = Absinthe.run(@add_query, SetmyInfo.GraphqlApi.Schema)
  end

  test "multiply query returns correct result" do
    assert {:ok, %{data: %{"multiply" => 12}}} =
             Absinthe.run(@multiply_query, SetmyInfo.GraphqlApi.Schema)
  end

  test "add query with negative numbers" do
    query = "{ add(a: -5, b: 3) }"
    assert {:ok, %{data: %{"add" => -2}}} = Absinthe.run(query, SetmyInfo.GraphqlApi.Schema)
  end
end

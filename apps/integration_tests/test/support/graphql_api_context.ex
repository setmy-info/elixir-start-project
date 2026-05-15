defmodule GraphqlApiContext do
  use WhiteBread.Context

  @port 4004
  @url ~c"http://localhost:#{@port}/graphql"

  given_(~r/^the GraphQL server is running$/, fn state ->
    {:ok, state}
  end)

  when_(~r/^I call add with a=(?<a>-?\d+) and b=(?<b>-?\d+)$/, fn state, %{a: a, b: b} ->
    {:ok, Map.put(state, :last_response, send_query("{ add(a: #{a}, b: #{b}) }"))}
  end)

  when_(~r/^I call multiply with a=(?<a>-?\d+) and b=(?<b>-?\d+)$/, fn state, %{a: a, b: b} ->
    {:ok, Map.put(state, :last_response, send_query("{ multiply(a: #{a}, b: #{b}) }"))}
  end)

  then_(~r/^the response should have add equal to (?<expected>-?\d+)$/, fn state,
                                                                           %{expected: expected} ->
    {200, body} = state.last_response
    expected_int = String.to_integer(expected)
    %{"data" => %{"add" => ^expected_int}} = body
    {:ok, state}
  end)

  then_(~r/^the response should have multiply equal to (?<expected>-?\d+)$/, fn state,
                                                                                %{
                                                                                  expected:
                                                                                    expected
                                                                                } ->
    {200, body} = state.last_response
    expected_int = String.to_integer(expected)
    %{"data" => %{"multiply" => ^expected_int}} = body
    {:ok, state}
  end)

  defp send_query(query) do
    body = Jason.encode!(%{query: query})

    {:ok, {{_, status, _}, _headers, resp_body}} =
      :httpc.request(
        :post,
        {@url, [], ~c"application/json", body},
        [],
        body_format: :binary
      )

    {status, Jason.decode!(resp_body)}
  end
end

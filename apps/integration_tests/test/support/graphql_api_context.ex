defmodule GraphqlApiContext do
  use WhiteBread.Context

  @port 4004
  @url ~c"http://localhost:#{@port}/graphql"

  # ── Math steps ──────────────────────────────────────────────────────────────

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

  # ── Person steps ─────────────────────────────────────────────────────────────

  when_(
    ~r/^I create a person with firstName "(?<first_name>[^"]+)" and lastName "(?<last_name>[^"]+)"$/,
    fn state, %{first_name: first_name, last_name: last_name} ->
      mutation = """
      mutation {
        createPerson(firstName: "#{first_name}", lastName: "#{last_name}") {
          id
          firstName
          lastName
        }
      }
      """

      {200, body} = send_query(mutation)
      %{"data" => %{"createPerson" => _}} = body
      {:ok, state}
    end
  )

  then_(
    ~r/^a person with firstName "(?<first_name>[^"]+)" and lastName "(?<last_name>[^"]+)" exists$/,
    fn state, %{first_name: first_name, last_name: last_name} ->
      {200, body} = send_query("{ persons { firstName lastName } }")
      persons = get_in(body, ["data", "persons"])
      true = Enum.any?(persons, &(&1["firstName"] == first_name && &1["lastName"] == last_name))
      {:ok, state}
    end
  )

  # ── Helpers ──────────────────────────────────────────────────────────────────

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

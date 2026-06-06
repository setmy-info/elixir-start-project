defmodule CalculatorContext do
  @moduledoc false
  use WhiteBread.Context

  @port 4006
  @url ~c"http://localhost:#{@port}/api/add"

  given_(~r/^the calculator REST server is running$/, fn state ->
    {:ok, state}
  end)

  when_(~r/^I POST add with a=(?<a>-?\d+) and b=(?<b>-?\d+)$/, fn state, %{a: a, b: b} ->
    a_int = String.to_integer(a)
    b_int = String.to_integer(b)
    response = send_add(a_int, b_int)
    {:ok, Map.put(state, :last_response, response)}
  end)

  then_(
    ~r/^the response should have result equal to (?<expected>-?\d+)$/,
    fn state, %{expected: expected} ->
      {200, body} = state.last_response
      expected_int = String.to_integer(expected)
      %{"result" => ^expected_int} = body
      {:ok, state}
    end
  )

  defp send_add(a, b) do
    body = Jason.encode!(%{a: a, b: b})

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

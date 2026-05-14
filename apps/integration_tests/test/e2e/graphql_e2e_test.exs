defmodule SetmyInfo.E2E.GraphqlTest do
  use ExUnit.Case, async: false

  require Logger

  @port 4003
  @url ~c"http://localhost:#{@port}/graphql"

  # Pre-integration-test: raise log level to :info so server start and HTTP
  # request logs are visible, then start the HTTP server once for the whole suite.
  setup_all do
    Logger.configure(level: :info)
    Application.ensure_all_started(:inets)

    {:ok, _} = Plug.Cowboy.http(SetmyInfo.GraphqlApi.Router, [], port: @port)
    Logger.info("[E2E] GraphQL server started on port #{@port}")

    # Post-integration-test: shut down server and restore log level.
    on_exit(fn ->
      Plug.Cowboy.shutdown(SetmyInfo.GraphqlApi.Router.Http)
      Logger.info("[E2E] GraphQL server stopped")
      Logger.configure(level: :warning)
    end)

    :ok
  end

  defp post_graphql(query) do
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

  describe "add" do
    test "add(2, 3) returns 5" do
      {200, body} = post_graphql("{ add(a: 2, b: 3) }")
      assert %{"data" => %{"add" => 5}} = body
    end

    test "add(0, 0) returns 0" do
      {200, body} = post_graphql("{ add(a: 0, b: 0) }")
      assert %{"data" => %{"add" => 0}} = body
    end

    test "add with negative numbers" do
      {200, body} = post_graphql("{ add(a: -4, b: 10) }")
      assert %{"data" => %{"add" => 6}} = body
    end
  end

  describe "multiply" do
    test "multiply(3, 4) returns 12" do
      {200, body} = post_graphql("{ multiply(a: 3, b: 4) }")
      assert %{"data" => %{"multiply" => 12}} = body
    end

    test "multiply(0, 99) returns 0" do
      {200, body} = post_graphql("{ multiply(a: 0, b: 99) }")
      assert %{"data" => %{"multiply" => 0}} = body
    end
  end

  describe "error handling" do
    test "missing required argument returns GraphQL error" do
      {200, body} = post_graphql("{ add(a: 1) }")
      assert %{"errors" => [_ | _]} = body
    end

    test "unknown field returns GraphQL error" do
      {200, body} = post_graphql("{ unknownField }")
      assert %{"errors" => [_ | _]} = body
    end
  end
end

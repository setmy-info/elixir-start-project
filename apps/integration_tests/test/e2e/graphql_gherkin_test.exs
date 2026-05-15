defmodule SetmyInfo.E2E.GraphqlGherkinTest do
  use ExUnit.Case, async: false

  require Logger

  # Separate port and ref from the plain ExUnit e2e test so both
  # can run in the same suite without binding the same listener.
  @port 4004
  @ref :gherkin_graphql_server

  # Pre-suite: start the HTTP server once, exactly like the ExUnit e2e test.
  # The Gherkin context knows nothing about server lifecycle.
  setup_all do
    Application.ensure_all_started(:inets)
    Logger.configure(level: :info)
    {:ok, _} = Plug.Cowboy.http(SetmyInfo.GraphqlApi.Router, [], port: @port, ref: @ref)
    Logger.info("[Gherkin E2E] GraphQL server started on port #{@port}")

    on_exit(fn ->
      Plug.Cowboy.shutdown(@ref)
      Logger.info("[Gherkin E2E] GraphQL server stopped")
      Logger.configure(level: :warning)
    end)

    :ok
  end

  test "Gherkin BDD scenarios pass against the running GraphQL server" do
    feature_path = Path.join(File.cwd!(), "features/")
    %{failures: failures} = WhiteBread.run(GraphqlApiContext, feature_path, [])

    failure_names =
      Enum.map(failures, fn {feature, _result} -> feature.name end)

    assert failures == [],
           "Gherkin feature(s) failed: #{Enum.join(failure_names, ", ")}"
  end
end

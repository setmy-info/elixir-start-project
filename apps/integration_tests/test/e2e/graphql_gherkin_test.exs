Code.require_file("../support/graphql_api_context.ex", __DIR__)

defmodule SetmyInfo.E2E.GraphqlGherkinTest do
  use ExUnit.Case, async: false

  require Logger

  # Separate port and ref from the plain ExUnit e2e test so both
  # can run in the same suite without binding the same listener.
  @port 4004
  @ref :gherkin_graphql_server

  # Pre-suite: start the HTTP server once and prepare the database.
  setup_all do
    Application.ensure_all_started(:inets)
    Logger.configure(level: :info)
    {:ok, _} = Plug.Cowboy.http(SetmyInfo.GraphqlApi.Router, [], port: @port, ref: @ref)
    Logger.info("[Gherkin E2E] GraphQL server started on port #{@port}")

    migrations_path = Application.app_dir(:core_logic, "priv/repo/migrations")
    Ecto.Migrator.run(SetmyInfo.CoreLogic.Repo, migrations_path, :up, all: true)
    SetmyInfo.CoreLogic.Repo.delete_all(SetmyInfo.CoreLogic.Person)
    Logger.info("[Gherkin E2E] Database migrated and persons table cleared")

    on_exit(fn ->
      Plug.Cowboy.shutdown(@ref)
      Logger.info("[Gherkin E2E] GraphQL server stopped")
      Logger.configure(level: :warning)
    end)

    :ok
  end

  test "Gherkin BDD scenarios pass against the running GraphQL server" do
    # __DIR__ is apps/integration_tests/test/e2e — go 4 levels up to umbrella root.
    # WhiteBread finder builds the glob pattern as dir_path <> "**", so the path
    # MUST end with "/" otherwise "features**" matches the directory itself, not
    # its contents, and no scenarios run.
    feature_path = Path.expand(Path.join(__DIR__, "../../../../features")) <> "/"
    %{failures: failures} = WhiteBread.run(GraphqlApiContext, feature_path, [])

    failure_names =
      Enum.map(failures, fn {feature, _result} -> feature.name end)

    assert failures == [],
           "Gherkin feature(s) failed: #{Enum.join(failure_names, ", ")}"
  end
end

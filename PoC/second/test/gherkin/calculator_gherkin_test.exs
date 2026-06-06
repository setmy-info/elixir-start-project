defmodule SetmyInfo.Gherkin.CalculatorGherkinTest do
  use ExUnit.Case, async: false

  @moduletag :gherkin
  @moduletag :slow

  require Logger

  @port 4006
  @ref :gherkin_calculator_server

  setup_all do
    Application.ensure_all_started(:inets)
    Logger.configure(level: :info)
    {:ok, _} = Plug.Cowboy.http(SetmyInfo.CalculatorRest.Router, [], port: @port, ref: @ref)
    Logger.info("[Gherkin] Calculator REST server started on port #{@port}")

    on_exit(fn ->
      Plug.Cowboy.shutdown(@ref)
      Logger.info("[Gherkin] Calculator REST server stopped")
      Logger.configure(level: :warning)
    end)

    :ok
  end

  test "Gherkin BDD scenarios pass against the running calculator REST server" do
    # __DIR__ is test/gherkin — go 2 levels up to project root, then into features/.
    # WhiteBread finder builds the glob pattern as dir_path <> "**", so the path
    # MUST end with "/" otherwise "features**" matches the directory itself and
    # no scenarios run.
    feature_path = Path.expand(Path.join(__DIR__, "../../features")) <> "/"
    %{failures: failures} = WhiteBread.run(CalculatorContext, feature_path, [])

    failure_names =
      Enum.map(failures, fn {feature, _result} -> feature.name end)

    assert failures == [],
           "Gherkin feature(s) failed: #{Enum.join(failure_names, ", ")}"
  end
end

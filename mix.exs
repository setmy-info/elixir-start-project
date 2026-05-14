defmodule ElixirStartProject.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :live,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def cli do
    [
      preferred_envs: [
        "test.unit": :test,
        "test.integration": :test,
        "test.all": :test,
        validate: :test
      ]
    ]
  end

  defp deps do
    []
  end

  @unit_test_paths ~w(
    apps/core_logic/test
    apps/runtime_engine/test
    apps/graphql_api/test
    apps/cli/test
    apps/wasm/test
  )

  defp aliases do
    [
      # ── Build ────────────────────────────────────────────────────────────
      build: ["deps.get", "compile"],

      # ── Validation ───────────────────────────────────────────────────────
      validate: ["compile --warnings-as-errors", "format --check-formatted"],

      # ── Tests ────────────────────────────────────────────────────────────
      # Passing explicit paths to `mix test` keeps everything in-process and
      # avoids env/subprocess issues with mix do --app.

      # Unit tests: all apps except integration_tests
      "test.unit": ["test #{Enum.join(@unit_test_paths, " ")}"],

      # Integration tests only
      "test.integration": ["test apps/integration_tests/test"],

      # All tests (unit + integration)
      "test.all": ["test"]
    ]
  end
end

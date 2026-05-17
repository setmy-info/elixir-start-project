defmodule ElixirStartProject.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      name: "Elixir Start Project",
      version: "0.1.0",
      start_permanent: Mix.env() == :live,
      deps: deps(),
      aliases: aliases(),
      # Task 4: unit-test coverage via ExCoveralls
      test_coverage: [tool: ExCoveralls],
      # Task 3: ExDoc umbrella documentation — output inside _build/ (gitignored)
      docs: [
        main: "readme",
        extras: ["README.md", "HEX_PUBLISHING.md", "CHANGELOG.md"],
        groups_for_extras: [Guides: ["README.md", "HEX_PUBLISHING.md", "CHANGELOG.md"]],
        output: "_build/doc"
      ]
    ]
  end

  def cli do
    [
      preferred_envs: [
        "test.unit": :test,
        "test.integration": :test,
        "test.e2e": :test,
        "test.gherkin": :test,
        "test.all": :test,
        "test.mutation": :test,
        "test.coverage": :test,
        validate: :test,
        # ExCoveralls tasks
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.lcov": :test
      ]
    ]
  end

  defp deps do
    [
      # Task 3: API documentation generation (Elixir-style, like Javadoc)
      {:ex_doc, "~> 0.34", only: [:dev, :ci], runtime: false},
      # Task 4: unit-test coverage with HTML report
      {:excoveralls, "~> 0.18", only: :test},
      # Task 2: mutation testing — run 'mix muzak' after 'mix deps.get'
      {:muzak, "~> 1.0", only: :test},
      # Task 6: dependency vulnerability audit (equiv. OWASP DependencyCheck)
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      # Task 6: static security analysis for Elixir/Plug code
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false}
    ]
  end

  @unit_test_paths ~w(
    apps/core_logic/test
    apps/runtime_engine/test
    apps/graphql_api/test
    apps/cli/test
    apps/wasm/test
    apps/lessons/test
  )

  defp aliases do
    [
      # ── Build ────────────────────────────────────────────────────────────
      build: ["deps.get", "compile"],

      # ── Validation ───────────────────────────────────────────────────────
      validate: ["compile --warnings-as-errors", "format --check-formatted"],

      # ── Documentation (Task 3) ────────────────────────────────────────────
      # Generates HTML docs in doc/ — equivalent of Javadoc / Maven site docs
      docs: ["docs"],

      # ── Tests ────────────────────────────────────────────────────────────
      # Passing explicit paths to `mix test` keeps everything in-process and
      # avoids env/subprocess issues with mix do --app.

      # Unit tests: all apps including lessons
      "test.unit": ["test #{Enum.join(@unit_test_paths, " ")}"],

      # Integration tests only
      "test.integration": ["test apps/integration_tests/test/integration"],

      # E2E tests only (server starts before suite, stops after)
      "test.e2e": ["test apps/integration_tests/test/e2e"],

      # Gherkin BDD e2e tests
      "test.gherkin": ["test apps/integration_tests/test/e2e/graphql_gherkin_test.exs"],

      # All tests: unit + integration + e2e (ExUnit, includes Gherkin wrapper)
      "test.all": ["test"],

      # Task 2: Mutation testing — unit test apps only
      # Runs muzak which mutates source code and re-runs tests to find untested paths.
      "test.mutation": ["muzak"],

      # Task 4: Coverage report for unit tests — HTML output in _build/cover/<app>/
      # Equivalent of Maven Surefire/JaCoCo HTML report
      "test.coverage": ["test.coverage"],

      # Task 6: Dependency vulnerability audit (equiv. OWASP DependencyCheck)
      audit: ["deps.audit"],

      # Task 6: Static security analysis (equiv. SpotBugs/FindSecBugs)
      security: ["sobelow --config"],

      # Task 6: Full report suite — docs + coverage + audit + security
      # Run this to generate the Elixir equivalent of a Maven site
      report: ["docs", "test.coverage", "deps.audit"]
    ]
  end
end

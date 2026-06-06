defmodule CalculatorApp.MixProject do
  use Mix.Project

  @version "2.0.0"
  @source_url "https://github.com/setmy-info/elixir-start-project"
  @docs_output "docs"

  @coveralls_commands [
    :coveralls,
    :"coveralls.detail",
    :"coveralls.html",
    :"coveralls.json",
    :"coveralls.post",
    :"coveralls.github"
  ]

  def project do
    [
      app: :calculator_app,
      version: @version,
      elixir: "~> 1.18",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :live,
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: [main_module: SetmyInfo.CalculatorCli.Main],
      deps: deps(),
      aliases: aliases(),
      cli: cli(),
      docs: docs(),
      releases: releases(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp description do
    "Calculator service demonstrating Elixir patterns: REST, GraphQL, CLI, BDD, mutation testing, and language lessons."
  end

  defp package do
    [
      name: "setmy_info_calculator_app",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/PoC/second/CHANGELOG.md"
      },
      files: ~w(lib priv mix.exs README.md LICENSE)
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"},
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},
      {:yaml_elixir, "~> 2.12"},
      {:toml, "~> 0.7"},
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, "~> 0.17"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", runtime: false},
      {:excoveralls, "~> 0.18", runtime: false},
      {:logger_backends, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.14"},
      {:stream_data, "~> 1.1", only: :test},
      {:white_bread, "4.4.0", only: :test},
      {:gherkin, "1.6.0", only: :test, override: true},
      {:muzak, "~> 1.0", only: :test}
    ]
  end

  def cli do
    [
      preferred_envs:
        [
          {:test, :test},
          {:credo, :dev},
          {:"deps.audit", :dev},
          {:"deps.hex_audit", :dev},
          {:quality, :dev},
          {:validate, :dev},
          {:"deps.check_versions", :dev},
          {:"deps.upgrade_versions", :dev},
          {:server, :local},
          {:"test.unit", :test},
          {:"test.integration", :test},
          {:"test.e2e", :test},
          {:"test.gherkin", :test},
          {:"test.mutation", :test},
          {:"docs.generate", :dev}
        ] ++ preferred_cli_env()
    ]
  end

  defp preferred_cli_env do
    Enum.map(@coveralls_commands, &{&1, :test})
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      output: @docs_output,
      source_ref: "main",
      source_url: @source_url
    ]
  end

  defp releases do
    [
      calculator_app: [
        config_providers: [
          {SetmyInfo.CalculatorApp.ConfigProvider, [path: "/etc/calculator_app/config.toml"]}
        ]
      ]
    ]
  end

  defp aliases do
    [
      validate: ["compile --warnings-as-errors", "format --check-formatted"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {SetmyInfo.CalculatorApp.Application, []},
      extra_applications: [:logger]
    ]
  end
end

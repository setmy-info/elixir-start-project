defmodule CalculatorApp.MixProject do
  use Mix.Project

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
      version: "2.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :live,
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: [main_module: SetmyInfo.CalculatorCli.Main],
      deps: deps(),
      aliases: aliases(),
      cli: cli(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"},
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", runtime: false},
      {:excoveralls, "~> 0.18", runtime: false},
      {:logger_backends, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.14"}
    ]
  end

  def cli do
    [
      preferred_envs:
        [
          {:test, :test},
          {:credo, :dev},
          {:"deps.audit", :dev},
          {:quality, :dev},
          {:validate, :dev},
          {:"deps.check_versions", :dev},
          {:"deps.upgrade_versions", :dev},
          {:server, :local},
          {:"test.unit", :test},
          {:"test.integration", :test},
          {:"test.e2e", :test},
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
      source_ref: "main"
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

defmodule SetmyInfo.CoreLogic.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/setmy-info/elixir-start-project"

  def project do
    [
      app: :core_logic,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :live,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SetmyInfo.CoreLogic.Application, []}
    ]
  end

  defp description do
    "Core business logic for SetmyInfo: Ecto schemas, YAML/TOML parsing, and OTP supervision tree."
  end

  defp package do
    [
      name: "setmy_info_core_logic",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      },
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "SetmyInfo.CoreLogic.Orchestrator",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19"},
      {:ecto_sqlite3, "~> 0.17"},
      {:yaml_elixir, "~> 2.12"},
      {:toml, "~> 0.7"},
      {:ex_doc, "~> 0.34", only: [:dev, :ci], runtime: false}
    ]
  end
end

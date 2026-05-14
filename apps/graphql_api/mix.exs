defmodule SetmyInfo.GraphqlApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :graphql_api,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :live,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SetmyInfo.GraphqlApi.Application, []}
    ]
  end

  defp deps do
    [
      {:core_logic, in_umbrella: true},
      {:runtime_engine, in_umbrella: true},
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"}
    ]
  end
end

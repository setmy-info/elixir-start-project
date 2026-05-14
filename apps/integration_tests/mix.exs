defmodule SetmyInfo.IntegrationTests.MixProject do
  use Mix.Project

  def project do
    [
      app: :integration_tests,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: false,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SetmyInfo.IntegrationTests.Application, []}
    ]
  end

  defp deps do
    [
      {:core_logic, in_umbrella: true},
      {:runtime_engine, in_umbrella: true}
    ]
  end
end

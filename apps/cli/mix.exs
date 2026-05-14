defmodule SetmyInfo.Cli.MixProject do
  use Mix.Project

  def project do
    [
      app: :cli,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :live,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SetmyInfo.Cli.Application, []}
    ]
  end

  defp deps do
    [
      {:runtime_engine, in_umbrella: true}
    ]
  end

  defp escript do
    [main_module: SetmyInfo.Cli.Main]
  end
end

defmodule SetmyInfo.RuntimeEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :runtime_engine,
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
      mod: {SetmyInfo.RuntimeEngine.Application, []}
    ]
  end

  defp deps do
    [
      {:core_logic, in_umbrella: true}
    ]
  end
end

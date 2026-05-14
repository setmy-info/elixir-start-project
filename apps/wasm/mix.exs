defmodule SetmyInfo.Wasm.MixProject do
  use Mix.Project

  def project do
    [
      app: :wasm,
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
      mod: {SetmyInfo.Wasm.Application, []}
    ]
  end

  defp deps do
    [
      {:runtime_engine, in_umbrella: true}
    ]
  end
end

defmodule SetmyInfo.CoreLogic.MixProject do
  use Mix.Project

  def project do
    [
      app: :core_logic,
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
      mod: {SetmyInfo.CoreLogic.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19"},
      {:ecto_sqlite3, "~> 0.17"}
    ]
  end
end

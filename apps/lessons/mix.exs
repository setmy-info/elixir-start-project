defmodule SetmyInfo.Lessons.MixProject do
  use Mix.Project

  def project do
    [
      app: :lessons,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: false,
      deps: deps(),
      docs: [
        main: "SetmyInfo.Lessons.DataTypes",
        groups_for_modules: [
          "Data & Types": [
            SetmyInfo.Lessons.DataTypes,
            SetmyInfo.Lessons.DataStructures
          ],
          "Control & Functions": [
            SetmyInfo.Lessons.FlowControl,
            SetmyInfo.Lessons.Operators,
            SetmyInfo.Lessons.Functions
          ],
          "Collections & Algorithms": [
            SetmyInfo.Lessons.Collections,
            SetmyInfo.Lessons.Algorithms
          ]
        ]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    []
  end
end

defmodule SetmyInfo.Lessons.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/setmy-info/elixir-start-project"

  def project do
    [
      app: :lessons,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: false,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      test_coverage: [summary: false]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp description do
    "Executable Elixir learning examples covering data types, collections, algorithms, and bitwise operations."
  end

  defp package do
    [
      name: "setmy_info_lessons",
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
      main: "SetmyInfo.Lessons.DataTypes",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"],
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
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: [:dev, :ci], runtime: false}
    ]
  end
end

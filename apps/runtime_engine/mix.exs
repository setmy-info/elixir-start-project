defmodule SetmyInfo.RuntimeEngine.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/setmy-info/elixir-start-project"

  def project do
    [
      app: :runtime_engine,
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
      mod: {SetmyInfo.RuntimeEngine.Application, []}
    ]
  end

  defp description do
    "OTP-based dynamic module loader with hot-code reload, GenServer workers, and ETS-backed registry."
  end

  defp package do
    [
      name: "setmy_info_runtime_engine",
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
      main: "SetmyInfo.RuntimeEngine.Executor",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      # When publishing to hex.pm, replace the line below with:
      # {:setmy_info_core_logic, "~> 0.1"},
      {:core_logic, in_umbrella: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end
end

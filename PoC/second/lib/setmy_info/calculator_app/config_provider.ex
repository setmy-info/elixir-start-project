defmodule SetmyInfo.CalculatorApp.ConfigProvider do
  @moduledoc """
  `Config.Provider` that loads runtime configuration from a TOML file.

  Called during OTP release boot (before any application starts) to merge
  file-based config values on top of the compile-time defaults.

  ## Resolution order

  1. `CALCULATOR_CONFIG_FILE` environment variable (runtime override)
  2. The `path:` option passed to `init/1`
  3. Built-in default: `/etc/calculator_app/config.toml`

  If the file is absent or cannot be parsed the existing config is returned
  unchanged — the provider never crashes the boot sequence.

  ## TOML schema

      [server]
      port     = 4000
      log_dir  = "log"
      log_file = "calculator_app.log"

      [database]
      path = "/var/lib/calculator_app/data.db"

  All sections and all keys are optional.

  ## Wiring into a Mix release

  In `mix.exs`:

      releases: [
        calculator_app: [
          config_providers: [
            {SetmyInfo.CalculatorApp.ConfigProvider,
             [path: "/etc/calculator_app/config.toml"]}
          ]
        ]
      ]
  """

  @behaviour Config.Provider

  @default_path "/etc/calculator_app/config.toml"

  @impl Config.Provider
  def init(opts) when is_list(opts), do: opts
  def init(path) when is_binary(path), do: [path: path]

  @impl Config.Provider
  def load(config, opts) do
    path = System.get_env("CALCULATOR_CONFIG_FILE") || Keyword.get(opts, :path, @default_path)

    with {:ok, content} <- File.read(path),
         {:ok, toml} <- Toml.decode(content) do
      Config.Reader.merge(config, to_app_config(toml))
    else
      _ -> config
    end
  end

  defp to_app_config(toml) do
    []
    |> merge_server(toml)
    |> merge_database(toml)
  end

  defp merge_server(acc, %{"server" => server}) do
    mapping = [{"port", :rest_port}, {"log_dir", :log_dir}, {"log_file", :log_file}]

    kv =
      for {toml_key, config_key} <- mapping,
          Map.has_key?(server, toml_key),
          do: {config_key, server[toml_key]}

    if kv == [], do: acc, else: Config.Reader.merge(acc, calculator_app: kv)
  end

  defp merge_server(acc, _), do: acc

  defp merge_database(acc, %{"database" => %{"path" => path}}) do
    Config.Reader.merge(acc, calculator_app: [{SetmyInfo.Ecto.Repo, [database: path]}])
  end

  defp merge_database(acc, _), do: acc
end

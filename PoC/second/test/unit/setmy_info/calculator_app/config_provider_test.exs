defmodule SetmyInfo.CalculatorApp.ConfigProviderTest do
  use ExUnit.Case, async: true

  alias SetmyInfo.CalculatorApp.ConfigProvider

  describe "init/1" do
    test "passes through a keyword list unchanged" do
      opts = [path: "/some/config.toml"]
      assert ConfigProvider.init(opts) == opts
    end

    test "wraps a binary path in a keyword list" do
      assert ConfigProvider.init("/some/config.toml") == [path: "/some/config.toml"]
    end
  end

  describe "load/2 — missing or broken file" do
    test "returns config unchanged when the file does not exist" do
      base = [calculator_app: [rest_port: 4000]]
      path = "/tmp/no_such_calculator_config_#{:rand.uniform(1_000_000)}.toml"
      assert ConfigProvider.load(base, path: path) == base
    end

    test "returns config unchanged when the TOML is malformed" do
      path = write_file("not = [valid toml ~~~")
      base = [calculator_app: [rest_port: 4000]]
      assert ConfigProvider.load(base, path: path) == base
    end
  end

  describe "load/2 — [server] section" do
    test "merges port into rest_port" do
      path = write_toml("[server]\nport = 9999\n")
      result = ConfigProvider.load([], path: path)
      assert calc_config(result)[:rest_port] == 9999
    end

    test "merges log_dir" do
      path = write_toml("[server]\nlog_dir = \"/var/log/app\"\n")
      result = ConfigProvider.load([], path: path)
      assert calc_config(result)[:log_dir] == "/var/log/app"
    end

    test "merges log_file" do
      path = write_toml("[server]\nlog_file = \"myapp.log\"\n")
      result = ConfigProvider.load([], path: path)
      assert calc_config(result)[:log_file] == "myapp.log"
    end

    test "overrides existing rest_port" do
      path = write_toml("[server]\nport = 5000\n")
      base = [calculator_app: [rest_port: 4000]]
      result = ConfigProvider.load(base, path: path)
      assert calc_config(result)[:rest_port] == 5000
    end

    test "leaves unmentioned keys at their existing values" do
      path = write_toml("[server]\nport = 7777\n")
      base = [calculator_app: [rest_port: 4000, log_dir: "log"]]
      result = ConfigProvider.load(base, path: path)
      assert calc_config(result)[:rest_port] == 7777
      assert calc_config(result)[:log_dir] == "log"
    end
  end

  describe "load/2 — [database] section" do
    test "merges database.path into Repo config" do
      path = write_toml("[database]\npath = \"/var/lib/calculator_app/data.db\"\n")
      result = ConfigProvider.load([], path: path)
      repo = Keyword.get(calc_config(result), SetmyInfo.Ecto.Repo, [])
      assert repo[:database] == "/var/lib/calculator_app/data.db"
    end

    test "database section without path key leaves Repo config untouched" do
      path = write_toml("[database]\n")
      base = [calculator_app: [{SetmyInfo.Ecto.Repo, [database: "/existing.db"]}]]
      result = ConfigProvider.load(base, path: path)
      repo = Keyword.get(calc_config(result), SetmyInfo.Ecto.Repo, [])
      assert repo[:database] == "/existing.db"
    end
  end

  describe "load/2 — full config file" do
    test "merges all sections together" do
      path =
        write_toml("""
        [server]
        port = 8080
        log_dir = "/var/log"
        log_file = "calc.log"

        [database]
        path = "/var/lib/calc.db"
        """)

      result = ConfigProvider.load([], path: path)
      cfg = calc_config(result)

      assert cfg[:rest_port] == 8080
      assert cfg[:log_dir] == "/var/log"
      assert cfg[:log_file] == "calc.log"
      assert Keyword.get(cfg, SetmyInfo.Ecto.Repo)[:database] == "/var/lib/calc.db"
    end
  end

  defp write_toml(content), do: write_file(content)

  defp write_file(content) do
    path = Path.join(System.tmp_dir!(), "cp_test_#{:rand.uniform(100_000_000)}.toml")
    File.write!(path, content)
    on_exit(fn -> File.rm(path) end)
    path
  end

  defp calc_config(config), do: Keyword.get(config, :calculator_app, [])
end

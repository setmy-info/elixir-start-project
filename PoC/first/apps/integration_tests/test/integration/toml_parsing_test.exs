defmodule SetmyInfo.Integration.TomlParsingTest do
  @moduledoc """
  Integration tests for TOML parsing via `SetmyInfo.CoreLogic.TomlParser`.

  Exercises parsing from both inline strings and fixture files, covering:
  - All TOML scalar types (string, integer, float, boolean)
  - TOML-specific types: Date, Time, NaiveDateTime, DateTime
  - Integer literals with hex, octal, and binary prefixes
  - Arrays (inline and multi-line)
  - Tables ([section]) and array-of-tables ([[section]])
  - Inline tables
  - Multi-line strings
  - Domain-object hydration (TOML → Person-like maps)
  - Error handling for malformed TOML
  """

  use ExUnit.Case

  alias SetmyInfo.CoreLogic.TomlParser

  @fixtures_dir Path.expand("../fixtures/toml", __DIR__)

  # ──────────────────── Inline string parsing ──────────────────────────────────

  describe "parse/1 — inline TOML string" do
    test "parses a flat key-value table" do
      toml = """
      name   = "Alice"
      age    = 30
      active = true
      """

      assert {:ok, result} = TomlParser.parse(toml)
      assert result["name"] == "Alice"
      assert result["age"] == 30
      assert result["active"] == true
    end

    test "parses all scalar types: string, integer, float, boolean" do
      toml = """
      str     = "hello"
      int     = 42
      flt     = 3.14
      bool_t  = true
      bool_f  = false
      """

      assert {:ok, result} = TomlParser.parse(toml)
      assert result["str"] == "hello"
      assert result["int"] == 42
      assert result["flt"] == 3.14
      assert result["bool_t"] == true
      assert result["bool_f"] == false
    end

    test "parses integer literals: decimal, hex, octal, binary" do
      toml = """
      dec = 255
      hex = 0xFF
      oct = 0o377
      bin = 0b11111111
      """

      assert {:ok, result} = TomlParser.parse(toml)
      assert result["dec"] == 255
      assert result["hex"] == 255
      assert result["oct"] == 255
      assert result["bin"] == 255
    end

    test "parses an inline array of scalars" do
      toml = ~s(colors = ["red", "green", "blue"])

      assert {:ok, %{"colors" => colors}} = TomlParser.parse(toml)
      assert colors == ["red", "green", "blue"]
    end

    test "parses a table ([section])" do
      toml = """
      [server]
      host = "localhost"
      port = 4000
      """

      assert {:ok, %{"server" => server}} = TomlParser.parse(toml)
      assert server["host"] == "localhost"
      assert server["port"] == 4000
    end

    test "parses a nested table" do
      toml = """
      [server]
      host = "localhost"
      port = 4000

      [server.tls]
      enabled   = false
      cert_path = "/etc/certs/server.crt"
      """

      assert {:ok, %{"server" => server}} = TomlParser.parse(toml)
      assert server["host"] == "localhost"
      assert server["tls"]["enabled"] == false
      assert server["tls"]["cert_path"] == "/etc/certs/server.crt"
    end

    test "parses an inline table" do
      toml = ~s(person = {first_name = "Alice", age = 30})

      assert {:ok, %{"person" => person}} = TomlParser.parse(toml)
      assert person["first_name"] == "Alice"
      assert person["age"] == 30
    end

    test "parses an array of tables ([[section]])" do
      toml = """
      [[items]]
      name  = "Widget A"
      price = 9.99

      [[items]]
      name  = "Widget B"
      price = 19.99
      """

      assert {:ok, %{"items" => [item_a, item_b]}} = TomlParser.parse(toml)
      assert item_a["name"] == "Widget A"
      assert item_a["price"] == 9.99
      assert item_b["name"] == "Widget B"
    end

    test "parses TOML date, time, and datetime types" do
      toml = """
      date     = 2024-01-15
      time     = 09:30:00
      dt_local = 1979-05-27T07:32:00
      dt_utc   = 1979-05-27T07:32:00Z
      """

      assert {:ok, result} = TomlParser.parse(toml)
      assert %Date{year: 2024, month: 1, day: 15} = result["date"]
      assert %Time{hour: 9, minute: 30, second: 0} = result["time"]
      assert %NaiveDateTime{year: 1979, month: 5, day: 27} = result["dt_local"]
      assert %DateTime{year: 1979, time_zone: "Etc/UTC"} = result["dt_utc"]
    end

    test "parses a multi-line basic string (preserves newlines)" do
      # Use ~s() delimiters to embed triple-quoted TOML without conflicting with
      # Elixir's """ heredoc terminator.
      toml = ~s(text = """\nline one\nline two\n"""\n)

      assert {:ok, %{"text" => text}} = TomlParser.parse(toml)
      assert String.contains?(text, "line one")
      assert String.contains?(text, "line two")
    end

    test "returns error tuple for malformed TOML" do
      bad_toml = "key = : invalid"
      assert {:error, _reason} = TomlParser.parse(bad_toml)
    end
  end

  describe "parse!/1 — raises on invalid TOML" do
    test "returns parsed data for valid TOML" do
      toml = "x = 1\ny = 2\n"
      result = TomlParser.parse!(toml)
      assert result["x"] == 1
      assert result["y"] == 2
    end

    test "raises on invalid TOML" do
      assert_raise Toml.Error, fn ->
        TomlParser.parse!("key = [unclosed")
      end
    end
  end

  # ──────────────────── File-based parsing ─────────────────────────────────────

  describe "parse_file/1 — config.toml" do
    test "loads application configuration from file" do
      path = Path.join(@fixtures_dir, "config.toml")

      assert {:ok, config} = TomlParser.parse_file(path)

      app = config["app"]
      assert app["name"] == "elixir-start-project"
      assert app["version"] == "0.1.0"
      assert app["debug"] == false

      db = config["database"]
      assert db["host"] == "localhost"
      assert db["port"] == 5432
      assert db["pool_size"] == 10

      server = config["server"]
      assert server["port"] == 4000
      assert "http://localhost:3000" in server["allowed_origins"]

      flags = config["feature_flags"]
      assert flags["hot_reload"] == true
      assert flags["wasm_engine"] == false
    end
  end

  describe "parse_file/1 — persons.toml (domain object hydration)" do
    test "loads a list of persons via array-of-tables" do
      path = Path.join(@fixtures_dir, "persons.toml")

      assert {:ok, %{"persons" => persons}} = TomlParser.parse_file(path)

      assert length(persons) == 3

      alice = Enum.find(persons, &(&1["first_name"] == "Alice"))
      assert alice["last_name"] == "Smith"
      assert alice["age"] == 30
      assert alice["active"] == true
      assert "admin" in alice["roles"]
      assert "developer" in alice["roles"]

      bob = Enum.find(persons, &(&1["first_name"] == "Bob"))
      assert bob["active"] == false
      assert bob["roles"] == ["developer"]
    end

    test "all active persons can be extracted by filtering the parsed list" do
      path = Path.join(@fixtures_dir, "persons.toml")
      assert {:ok, %{"persons" => persons}} = TomlParser.parse_file(path)

      active = Enum.filter(persons, & &1["active"])
      names = Enum.map(active, & &1["first_name"])

      assert "Alice" in names
      assert "Carol" in names
      refute "Bob" in names
    end

    test "parsed persons can seed Ecto changesets" do
      path = Path.join(@fixtures_dir, "persons.toml")
      assert {:ok, %{"persons" => persons}} = TomlParser.parse_file(path)

      changesets =
        Enum.map(persons, fn p ->
          SetmyInfo.CoreLogic.Person.changeset(
            %SetmyInfo.CoreLogic.Person{},
            %{first_name: p["first_name"], last_name: p["last_name"]}
          )
        end)

      assert Enum.all?(changesets, & &1.valid?)
    end
  end

  describe "parse_file/1 — types.toml (all TOML types)" do
    test "scalar types map to the correct Elixir types" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      assert is_binary(data["string_value"])
      assert is_integer(data["integer_value"])
      assert data["integer_value"] == 42
      assert is_float(data["float_value"])
      assert data["float_value"] == 3.14
      assert data["flag_yes"] == true
      assert data["flag_no"] == false
    end

    test "integer literal formats (hex, octal, binary) all decode correctly" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      assert data["hex_int"] == 0xDEADBEEF
      assert data["octal_int"] == 0o777
      assert data["binary_int"] == 0b11010110
      assert data["underscored_int"] == 1_000_000
    end

    test "TOML date type maps to Date.t()" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      assert %Date{year: 2024, month: 1, day: 15} = data["date_val"]
    end

    test "TOML time type maps to Time.t()" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      assert %Time{hour: 9, minute: 30, second: 0} = data["time_val"]
    end

    test "local datetime maps to NaiveDateTime.t()" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      assert %NaiveDateTime{year: 1979, month: 5, day: 27} = data["datetime_local"]
    end

    test "offset datetime maps to DateTime.t()" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      assert %DateTime{year: 1979, time_zone: "Etc/UTC"} = data["datetime_utc"]
    end

    test "nested table ([address]) is parsed to a map" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, %{"address" => address}} = TomlParser.parse_file(path)

      assert address["city"] == "Tallinn"
      assert address["country"] == "Estonia"
    end

    test "array-of-tables ([[products]]) maps to a list of maps" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, %{"products" => products}} = TomlParser.parse_file(path)

      assert length(products) == 2
      widget_a = Enum.find(products, &(&1["name"] == "Widget A"))
      assert widget_a["price"] == 9.99
      assert widget_a["in_stock"] == true
    end

    test "inline table is parsed to a map" do
      path = Path.join(@fixtures_dir, "types.toml")
      assert {:ok, data} = TomlParser.parse_file(path)

      person = data["inline_person"]
      assert person["first_name"] == "Alice"
      assert person["age"] == 30
    end
  end

  describe "parse_file/1 — error cases" do
    test "returns error tuple for non-existent file" do
      assert {:error, _reason} = TomlParser.parse_file("/no/such/file.toml")
    end
  end
end

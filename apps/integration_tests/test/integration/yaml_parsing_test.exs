defmodule SetmyInfo.Integration.YamlParsingTest do
  @moduledoc """
  Integration tests for YAML parsing via `SetmyInfo.CoreLogic.YamlParser`.

  Exercises parsing from both inline strings and fixture files, covering:
  - All YAML scalar types (string, integer, float, boolean, null)
  - Sequences (lists) and mappings (maps)
  - Nested structures
  - Multi-line literal and folded strings
  - YAML anchors and aliases
  - Multi-document YAML (`---` separator)
  - Domain-object hydration (YAML → Person-like maps)
  - Error handling for malformed YAML
  """

  use ExUnit.Case

  alias SetmyInfo.CoreLogic.YamlParser

  @fixtures_dir Path.expand("../fixtures/yaml", __DIR__)

  # ──────────────────── Inline string parsing ──────────────────────────────────

  describe "parse/1 — inline YAML string" do
    test "parses a flat key-value map" do
      yaml = """
      name: Alice
      age: 30
      active: true
      """

      assert {:ok, result} = YamlParser.parse(yaml)
      assert result["name"] == "Alice"
      assert result["age"] == 30
      assert result["active"] == true
    end

    test "parses all scalar types: string, integer, float, boolean, null" do
      yaml = """
      str:   hello
      int:   42
      float: 3.14
      bool_t: true
      bool_f: false
      null_v: ~
      """

      assert {:ok, result} = YamlParser.parse(yaml)
      assert result["str"] == "hello"
      assert result["int"] == 42
      assert result["float"] == 3.14
      assert result["bool_t"] == true
      assert result["bool_f"] == false
      assert result["null_v"] == nil
    end

    test "parses a sequence (list) of scalars" do
      yaml = """
      colors:
        - red
        - green
        - blue
      """

      assert {:ok, %{"colors" => colors}} = YamlParser.parse(yaml)
      assert colors == ["red", "green", "blue"]
    end

    test "parses a list of maps" do
      yaml = """
      items:
        - name: Widget A
          price: 9.99
        - name: Widget B
          price: 19.99
      """

      assert {:ok, %{"items" => [item_a, item_b]}} = YamlParser.parse(yaml)
      assert item_a["name"] == "Widget A"
      assert item_a["price"] == 9.99
      assert item_b["name"] == "Widget B"
    end

    test "parses a nested mapping" do
      yaml = """
      server:
        host: localhost
        port: 4000
        tls:
          enabled: false
          cert_path: ~
      """

      assert {:ok, %{"server" => server}} = YamlParser.parse(yaml)
      assert server["host"] == "localhost"
      assert server["port"] == 4000
      assert server["tls"]["enabled"] == false
      assert server["tls"]["cert_path"] == nil
    end

    test "parses literal block scalar (preserves newlines)" do
      yaml = "text: |\n  line one\n  line two\n"

      assert {:ok, %{"text" => text}} = YamlParser.parse(yaml)
      assert text == "line one\nline two\n"
    end

    test "parses folded block scalar (newlines → spaces)" do
      yaml = "text: >\n  line one\n  line two\n"

      assert {:ok, %{"text" => text}} = YamlParser.parse(yaml)
      assert text == "line one line two\n"
    end

    test "returns error tuple for malformed YAML" do
      bad_yaml = "key: : invalid : structure"
      result = YamlParser.parse(bad_yaml)
      assert {:error, _reason} = result
    end
  end

  describe "parse!/1 — raises on invalid YAML" do
    test "returns parsed data for valid YAML" do
      yaml = "x: 1\ny: 2\n"
      result = YamlParser.parse!(yaml)
      assert result["x"] == 1
      assert result["y"] == 2
    end

    test "raises on invalid YAML" do
      assert_raise(YamlElixir.ParsingError, fn ->
        YamlParser.parse!("{bad yaml [")
      end)
    end
  end

  # ──────────────────── File-based parsing ─────────────────────────────────────

  describe "parse_file/1 — config.yml" do
    test "loads application configuration from file" do
      path = Path.join(@fixtures_dir, "config.yml")

      assert {:ok, config} = YamlParser.parse_file(path)

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

  describe "parse_file/1 — persons.yml (domain object hydration)" do
    test "loads a list of persons and extracts domain fields" do
      path = Path.join(@fixtures_dir, "persons.yml")

      assert {:ok, %{"persons" => persons}} = YamlParser.parse_file(path)

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
      path = Path.join(@fixtures_dir, "persons.yml")
      assert {:ok, %{"persons" => persons}} = YamlParser.parse_file(path)

      active = Enum.filter(persons, & &1["active"])
      names = Enum.map(active, & &1["first_name"])

      assert "Alice" in names
      assert "Carol" in names
      refute "Bob" in names
    end

    test "parsed persons can seed Ecto changesets" do
      path = Path.join(@fixtures_dir, "persons.yml")
      assert {:ok, %{"persons" => persons}} = YamlParser.parse_file(path)

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

  describe "parse_file/1 — types.yml (all YAML types)" do
    test "all YAML scalar types map to the correct Elixir types" do
      path = Path.join(@fixtures_dir, "types.yml")
      assert {:ok, data} = YamlParser.parse_file(path)

      assert is_binary(data["string_value"])
      assert is_integer(data["integer_value"])
      assert data["integer_value"] == 42
      assert is_float(data["float_value"])
      assert data["float_value"] == 3.14
      assert data["boolean_true"] == true
      assert data["boolean_false"] == false
      assert data["null_tilde"] == nil
      assert data["null_explicit"] == nil
    end

    test "nested map is parsed correctly" do
      path = Path.join(@fixtures_dir, "types.yml")
      assert {:ok, %{"address" => address}} = YamlParser.parse_file(path)

      assert address["city"] == "Tallinn"
      assert address["country"] == "Estonia"
    end

    test "list of maps is parsed to a list of Elixir maps" do
      path = Path.join(@fixtures_dir, "types.yml")
      assert {:ok, %{"products" => products}} = YamlParser.parse_file(path)

      assert length(products) == 2
      widget_a = Enum.find(products, &(&1["name"] == "Widget A"))
      assert widget_a["price"] == 9.99
      assert widget_a["in_stock"] == true
    end

    test "YAML anchors and aliases share the same data structure (DRY reuse)" do
      path = Path.join(@fixtures_dir, "types.yml")
      assert {:ok, data} = YamlParser.parse_file(path)

      production = data["production"]
      staging = data["staging"]

      assert production["host"] == "prod.example.com"
      assert production["connection"]["timeout"] == 30
      assert production["connection"]["retries"] == 3

      assert staging["host"] == "staging.example.com"
      assert staging["connection"]["timeout"] == 30
      assert staging["connection"]["retries"] == 3
      assert staging["connection"] == production["connection"]
    end
  end

  describe "parse_file/1 — error cases" do
    test "returns error tuple for non-existent file" do
      assert {:error, _reason} = YamlParser.parse_file("/no/such/file.yml")
    end
  end

  # ──────────────────── Multi-document YAML ────────────────────────────────────

  describe "parse_all/1 — multi-document YAML string" do
    test "parses multiple documents separated by ---" do
      yaml = """
      ---
      env: dev
      debug: true
      ---
      env: prod
      debug: false
      """

      assert {:ok, [doc1, doc2]} = YamlParser.parse_all(yaml)
      assert doc1["env"] == "dev"
      assert doc1["debug"] == true
      assert doc2["env"] == "prod"
      assert doc2["debug"] == false
    end
  end

  describe "parse_all_file/1 — multi_doc.yml" do
    test "loads all YAML documents from a multi-doc file" do
      path = Path.join(@fixtures_dir, "multi_doc.yml")

      assert {:ok, docs} = YamlParser.parse_all_file(path)
      assert length(docs) == 3

      kinds = Enum.map(docs, & &1["kind"])
      assert Enum.all?(kinds, &(&1 == "ConfigMap"))

      names = Enum.map(docs, & &1["name"])
      assert "app-config" in names
      assert "dev-overrides" in names
      assert "prod-overrides" in names
    end
  end
end

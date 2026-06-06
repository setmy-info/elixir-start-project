defmodule SetmyInfo.CalculatorRest.RouterTest do
  use ExUnit.Case, async: true

  @moduletag :integration

  import Plug.Conn
  import Plug.Test

  alias SetmyInfo.CalculatorRest.{RateLimiter, Router}

  @web_app_dir Path.join(:code.priv_dir(:calculator_app), "static")

  setup do
    static_dir = @web_app_dir
    File.mkdir_p!(static_dir)

    originals =
      for file_name <- ["index.html", "app.css", "app.js", "favicon.ico"], into: %{} do
        path = Path.join(static_dir, file_name)
        {file_name, if(File.exists?(path), do: File.read!(path), else: :missing)}
      end

    on_exit(fn ->
      Enum.each(originals, fn {file_name, content} ->
        path = Path.join(static_dir, file_name)

        case content do
          :missing -> File.rm(path)
          _ -> File.write!(path, content)
        end
      end)
    end)

    :ok
  end

  test "POST /api/add returns the sum as json" do
    conn =
      conn(:post, "/api/add", Jason.encode!(%{a: 2, b: 3}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["result"] == 5
    assert is_binary(body["at"])
  end

  test "POST /api/add returns 400 when a parameter is missing" do
    conn =
      conn(:post, "/api/add", Jason.encode!(%{a: 2}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 400

    assert Jason.decode!(conn.resp_body) == %{
             "error" => "Request body must contain integer fields 'a' and 'b'."
           }
  end

  test "POST /api/add returns 400 when values are not integers" do
    conn =
      conn(:post, "/api/add", Jason.encode!(%{a: "2", b: 3}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 400

    assert Jason.decode!(conn.resp_body) == %{
             "error" => "Request body must contain integer fields 'a' and 'b'."
           }
  end

  test "POST /api/add returns 400 when a value exceeds int32 range" do
    conn =
      conn(:post, "/api/add", Jason.encode!(%{a: 2_147_483_648, b: 0}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 400

    assert Jason.decode!(conn.resp_body) == %{
             "error" => "Fields 'a' and 'b' must be 32-bit integers (-2147483648 to 2147483647)."
           }
  end

  test "POST /api/add returns 415 when content type is not json" do
    conn =
      conn(:post, "/api/add", "a=2&b=3")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 415
    assert Jason.decode!(conn.resp_body) == %{"error" => "Content-Type must be application/json."}
  end

  test "POST /api/add returns 406 when accept does not allow json" do
    conn =
      conn(:post, "/api/add", Jason.encode!(%{a: 2, b: 3}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "text/html")
      |> Router.call([])

    assert conn.status == 406
    assert Jason.decode!(conn.resp_body) == %{"error" => "Accept must allow application/json."}
  end

  test "POST /api/graphql returns the sum and UTC timestamp through GraphQL" do
    conn =
      conn(
        :post,
        "/api/graphql",
        Jason.encode!(%{
          query: "query Add($a: Int!, $b: Int!) { add(a: $a, b: $b) { result at } }",
          variables: %{a: 4, b: 6}
        })
      )
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert get_in(body, ["data", "add", "result"]) == 10
    assert is_binary(get_in(body, ["data", "add", "at"]))
    assert String.ends_with?(get_in(body, ["data", "add", "at"]), "Z")
  end

  test "GET / serves static html from the same server" do
    static_dir = @web_app_dir
    File.write!(Path.join(static_dir, "index.html"), "<html><body>Calculator</body></html>")

    conn =
      conn(:get, "/")
      |> put_req_header("accept", "text/html")
      |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body =~ "Calculator"

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(&String.starts_with?(&1, "text/html"))
  end

  test "web app index includes controls to call add service" do
    index_html = File.read!(Path.join(@web_app_dir, "index.html"))

    assert index_html =~ "add-form"
    assert index_html =~ "transport"
    assert index_html =~ "number-a"
    assert index_html =~ "number-b"
    assert index_html =~ "Add numbers"
    assert index_html =~ "/api/add"
    assert index_html =~ "/api/graphql"
    assert index_html =~ "/graphiql"
  end

  test "GET /graphiql serves the built-in GraphQL request UI" do
    conn =
      conn(:get, "/graphiql")
      |> put_req_header("accept", "text/html")
      |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body =~ "GraphiQL"

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(&String.starts_with?(&1, "text/html"))
  end

  test "GET /swagger.json serves the REST OpenAPI document" do
    conn =
      conn(:get, "/swagger.json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 200

    payload = Jason.decode!(conn.resp_body)

    assert payload["openapi"] == "3.2.0"
    assert get_in(payload, ["info", "version"]) == "2.0"
    assert get_in(payload, ["paths", "/api/add", "post", "operationId"]) == "addIntegers"
    assert get_in(payload, ["paths", "/api/calc", "post", "operationId"]) == "calculate"
    assert get_in(payload, ["paths", "/api/batch", "post", "operationId"]) == "batchAdd"
    assert get_in(payload, ["paths", "/api/history", "get", "operationId"]) == "getHistory"
    assert get_in(payload, ["paths", "/api/total", "get", "operationId"]) == "getRunningTotal"
    assert get_in(payload, ["servers"]) |> hd() |> Map.fetch!("url") == "http://localhost:4000"
    assert get_in(payload, ["components", "schemas", "AddRequest", "type"]) == "object"
    assert get_in(payload, ["components", "schemas", "HistoryEntry", "type"]) == "object"
    assert get_in(payload, ["components", "schemas", "ErrorResponse", "type"]) == "object"

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(&String.starts_with?(&1, "application/json"))
  end

  test "GET /swagger serves the Swagger UI page" do
    conn =
      conn(:get, "/swagger")
      |> put_req_header("accept", "text/html")
      |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body =~ "SwaggerUIBundle"
    assert conn.resp_body =~ "/openapi.json"

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(&String.starts_with?(&1, "text/html"))
  end

  test "GET /app.css serves static css from the same server" do
    static_dir = @web_app_dir
    File.write!(Path.join(static_dir, "app.css"), "body { color: #333; }")

    conn =
      conn(:get, "/app.css")
      |> put_req_header("accept", "text/css")
      |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body =~ "color"

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(&String.starts_with?(&1, "text/css"))
  end

  test "GET /app.js serves static javascript from the same server" do
    static_dir = @web_app_dir
    File.write!(Path.join(static_dir, "app.js"), "console.log('calculator');")

    conn =
      conn(:get, "/app.js")
      |> put_req_header("accept", "application/javascript")
      |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body =~ "calculator"

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(&String.contains?(&1, "javascript"))
  end

  test "GET /favicon.ico serves the favicon from the same server" do
    static_dir = @web_app_dir
    favicon_content = <<0, 0, 1, 0>>
    File.write!(Path.join(static_dir, "favicon.ico"), favicon_content)

    conn =
      conn(:get, "/favicon.ico")
      |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body == favicon_content

    assert get_resp_header(conn, "content-type")
           |> Enum.any?(fn header ->
             String.contains?(header, "image/x-icon") or
               String.contains?(header, "image/vnd.microsoft.icon")
           end)
  end

  describe "POST /api/calc — Operation behaviour dispatch" do
    test "add operation returns the sum" do
      conn =
        conn(:post, "/api/calc", Jason.encode!(%{op: "add", a: 4, b: 6}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body)["result"] == 10
    end

    test "subtract operation returns the difference" do
      conn =
        conn(:post, "/api/calc", Jason.encode!(%{op: "subtract", a: 10, b: 3}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body)["result"] == 7
    end

    test "divide by zero returns 400" do
      conn =
        conn(:post, "/api/calc", Jason.encode!(%{op: "divide", a: 10, b: 0}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["error"] =~ "zero"
    end

    test "unknown operation returns 400" do
      conn =
        conn(:post, "/api/calc", Jason.encode!(%{op: "modulo", a: 10, b: 3}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["error"] =~ "Unknown operation"
    end
  end

  describe "POST /api/batch — parallel addition" do
    test "returns results for each pair in order" do
      pairs = [%{a: 1, b: 2}, %{a: 3, b: 4}, %{a: 5, b: 6}]

      conn =
        conn(:post, "/api/batch", Jason.encode!(%{pairs: pairs}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 200
      results = Jason.decode!(conn.resp_body)["results"]
      assert Enum.map(results, & &1["result"]) == [3, 7, 11]
    end

    test "returns 400 when pairs array is missing" do
      conn =
        conn(:post, "/api/batch", Jason.encode!(%{a: 1}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 400
    end
  end

  describe "GET /api/history" do
    test "returns empty history when History GenServer is not running" do
      conn =
        conn(:get, "/api/history")
        |> Router.call([])

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{"history" => []}
    end
  end

  @tag :concurrent
  test "handles concurrent requests without interference" do
    tasks =
      for n <- 1..30 do
        Task.async(fn ->
          conn(:post, "/api/add", Jason.encode!(%{a: n, b: n}))
          |> put_req_header("content-type", "application/json")
          |> put_req_header("accept", "application/json")
          |> Router.call([])
        end)
      end

    results = Task.await_many(tasks, 5_000)

    for {result_conn, n} <- Enum.zip(results, 1..30) do
      assert result_conn.status == 200
      assert Jason.decode!(result_conn.resp_body)["result"] == n * 2
    end
  end

  describe "CORS headers" do
    test "all API responses include Access-Control-Allow-Origin header" do
      conn =
        conn(:post, "/api/add", Jason.encode!(%{a: 1, b: 2}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert get_resp_header(conn, "access-control-allow-origin") == ["*"]
      assert get_resp_header(conn, "access-control-allow-methods") != []
    end

    test "OPTIONS preflight returns 204 with CORS headers" do
      conn =
        conn(:options, "/api/add")
        |> put_req_header("origin", "https://example.com")
        |> put_req_header("access-control-request-method", "POST")
        |> Router.call([])

      assert conn.status == 204
      assert get_resp_header(conn, "access-control-allow-origin") == ["*"]
      assert get_resp_header(conn, "access-control-allow-methods") != []
      assert get_resp_header(conn, "access-control-allow-headers") != []
    end

    test "404 responses also carry CORS headers" do
      conn =
        conn(:get, "/api/no-such-path")
        |> Router.call([])

      assert conn.status == 404
      assert get_resp_header(conn, "access-control-allow-origin") == ["*"]
    end
  end

  describe "GET /api/total — RunningTotal Agent" do
    test "returns 200 with total 0 when agent is not running" do
      conn =
        conn(:get, "/api/total")
        |> Router.call([])

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body)["total"] == 0
    end
  end

  describe "POST /api/total — RunningTotal Agent" do
    test "returns 503 when agent is not running" do
      conn =
        conn(:post, "/api/total", Jason.encode!(%{value: 5}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 503
      assert Jason.decode!(conn.resp_body)["error"] =~ "not available"
    end

    test "returns 400 when value is not an integer" do
      conn =
        conn(:post, "/api/total", Jason.encode!(%{value: "five"}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 400
    end
  end

  describe "DELETE /api/total — RunningTotal Agent" do
    test "returns 200 with total 0 regardless of agent state" do
      conn =
        conn(:delete, "/api/total")
        |> Router.call([])

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body)["total"] == 0
    end
  end

  describe "rate limiter" do
    setup do
      # Start a fresh rate limiter for isolation; stop it on exit.
      case RateLimiter.start_link([]) do
        {:ok, pid} -> on_exit(fn -> Process.exit(pid, :kill) end)
        {:error, {:already_started, _}} -> :ok
      end

      :ok
    end

    test "returns 429 when the per-IP limit is exceeded" do
      test_ip = "10.99.0.1"
      window = div(System.system_time(:second), 60)
      limit = Application.get_env(:calculator_app, :rate_limit_max_requests, 100)

      # Seed the ETS table with count at the limit
      :ets.insert(:rate_limiter, {{test_ip, window}, limit})

      conn =
        conn(:post, "/api/add", Jason.encode!(%{a: 1, b: 2}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Map.put(:remote_ip, {10, 99, 0, 1})
        |> Router.call([])

      assert conn.status == 429
      assert get_resp_header(conn, "retry-after") == ["60"]
      assert Jason.decode!(conn.resp_body)["error"] =~ "Rate limit exceeded"
    end

    test "requests below the limit are allowed" do
      conn =
        conn(:post, "/api/add", Jason.encode!(%{a: 3, b: 4}))
        |> put_req_header("content-type", "application/json")
        |> put_req_header("accept", "application/json")
        |> Router.call([])

      assert conn.status == 200
    end

    test "rate limit does not apply to static files" do
      test_ip = "10.99.0.2"
      window = div(System.system_time(:second), 60)
      limit = Application.get_env(:calculator_app, :rate_limit_max_requests, 100)

      # Seed beyond the limit
      :ets.insert(:rate_limiter, {{test_ip, window}, limit + 50})

      # Static file path is exempt
      conn =
        conn(:get, "/")
        |> Map.put(:remote_ip, {10, 99, 0, 2})
        |> Router.call([])

      refute conn.status == 429
    end
  end
end

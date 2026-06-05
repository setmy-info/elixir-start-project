defmodule SetmyInfo.CalculatorRest.RouterTest do
  use ExUnit.Case, async: true
  import Plug.Conn
  import Plug.Test

  alias SetmyInfo.CalculatorRest.Router

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
    assert Jason.decode!(conn.resp_body) == %{"result" => 5}
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

  test "POST /api/graphql returns the sum through GraphQL" do
    conn =
      conn(
        :post,
        "/api/graphql",
        Jason.encode!(%{
          query: "query Add($a: Int!, $b: Int!) { add(a: $a, b: $b) }",
          variables: %{a: 4, b: 6}
        })
      )
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> Router.call([])

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"data" => %{"add" => 10}}
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
    assert get_in(payload, ["paths", "/api/add", "post", "summary"]) == "Add two integers"
    assert get_in(payload, ["components", "schemas", "AddRequest", "type"]) == "object"
    assert get_in(payload, ["components", "schemas", "AddResponse", "type"]) == "object"
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
    assert conn.resp_body =~ "/swagger.json"

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
end

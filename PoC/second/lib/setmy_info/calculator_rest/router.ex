defmodule SetmyInfo.CalculatorRest.Router do
  use Plug.Router

  @moduledoc """
  Plug router that serves the calculator REST API, GraphQL API, GraphiQL, and the static web app.

  The `/api/add` endpoint accepts JSON input with integer fields `a` and `b`.
  Static files are served from `priv/static/` on the same port.
  """

  forward("/api/graphql",
    to: Absinthe.Plug,
    init_opts: [schema: SetmyInfo.CalculatorRest.Schema]
  )

  forward("/graphiql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [
      schema: SetmyInfo.CalculatorRest.Schema,
      interface: :simple,
      json_codec: Jason
    ]
  )

  import Plug.Conn

  alias SetmyInfo.CalculatorRest.Swagger
  alias SetmyInfo.Math.MathService

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: {:calculator_app, "priv/static"},
    only: ~w(index.html app.css app.js favicon.ico)
  )

  plug(:ensure_json_headers)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/api/add" do
    with %{"a" => a, "b" => b} <- conn.body_params,
         true <- is_integer(a) and is_integer(b) do
      result = MathService.add(a, b)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{result: result}))
    else
      _ ->
        send_bad_request(conn, "Request body must contain integer fields 'a' and 'b'.")
    end
  end

  get "/swagger.json" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Swagger.json())
  end

  get "/swagger" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Swagger.ui_html())
  end

  get "/" do
    index_path = Path.join(:code.priv_dir(:calculator_app), "static/index.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, index_path)
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{error: "Not found"}))
  end

  @doc false
  defp send_bad_request(conn, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{error: message}))
  end

  @doc false
  defp ensure_json_headers(%Plug.Conn{request_path: "/api/add"} = conn, _opts) do
    cond do
      not json_content_type?(conn) ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(415, Jason.encode!(%{error: "Content-Type must be application/json."}))
        |> halt()

      not accepts_json?(conn) ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(406, Jason.encode!(%{error: "Accept must allow application/json."}))
        |> halt()

      true ->
        conn
    end
  end

  @doc false
  defp ensure_json_headers(conn, _opts), do: conn

  @doc false
  defp json_content_type?(conn) do
    conn
    |> get_req_header("content-type")
    |> Enum.any?(&String.starts_with?(String.downcase(&1), "application/json"))
  end

  @doc false
  defp accepts_json?(conn) do
    case get_req_header(conn, "accept") do
      [] -> true
      values -> Enum.any?(values, &accept_header_allows_json?/1)
    end
  end

  @doc false
  defp accept_header_allows_json?(header_value) do
    header_value
    |> String.downcase()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.any?(fn media_range ->
      media_range == "*/*" or
        String.starts_with?(media_range, "application/json") or
        String.starts_with?(media_range, "application/*")
    end)
  end
end

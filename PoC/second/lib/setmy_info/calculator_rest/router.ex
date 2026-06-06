defmodule SetmyInfo.CalculatorRest.Router do
  use Plug.Router

  @moduledoc """
  Plug router that serves the calculator REST API, GraphQL API, Swagger, and static assets.

  ## Plug pipeline (in order)

  1. `Plug.RequestId`  — generates a unique `x-request-id` per request
  2. `Plug.Telemetry`  — emits `[:calculator_app, :http, :stop]` with duration
  3. `Plug.Logger`     — logs each request (picks up `request_id` from metadata)
  4. `CorsPlug`        — CORS headers + OPTIONS preflight
  5. `RateLimitPlug`   — per-IP fixed-window limiter on `/api/*`
  6. `Plug.Static`     — static files from `priv/static/`
  7. `:ensure_json_headers` — enforces Content-Type / Accept for JSON API paths
  8. `Plug.Parsers`    — JSON body parsing
  9. `:match` / `:dispatch`

  ## Endpoints

  | Method | Path           | Description                                      |
  |--------|----------------|--------------------------------------------------|
  | POST   | `/api/add`     | Add two int32 integers                           |
  | POST   | `/api/calc`    | Generic operation via `Operation` behaviour      |
  | POST   | `/api/batch`   | Parallel addition of a list of pairs             |
  | GET    | `/api/history` | Return recent operations from `History` GenServer|
  | POST   | `/api/graphql` | GraphQL endpoint (Absinthe)                      |
  | GET    | `/graphiql`    | GraphiQL interactive UI                          |
  | GET    | `/swagger.json`| OpenAPI 3.2 spec                                 |
  | GET    | `/swagger`     | Swagger UI                                       |
  | GET    | `/`            | Static web frontend                              |
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

  alias SetmyInfo.CalculatorApp.{Cache, History, Operation, Parallel}
  alias SetmyInfo.CalculatorRest.{CorsPlug, RateLimitPlug, Swagger}
  alias SetmyInfo.Math.MathService

  @type add_result :: %{result: integer()}
  @type calc_result :: %{result: number()}
  @type batch_result :: %{results: [%{a: integer(), b: integer(), result: integer()}]}
  @type error_response :: %{error: String.t()}

  @int32_min -2_147_483_648
  @int32_max 2_147_483_647

  @json_api_paths ~w(/api/add /api/calc /api/batch)

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:calculator_app, :http])
  plug(Plug.Logger)
  plug(CorsPlug)
  plug(RateLimitPlug)

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
         :ok <- validate_integers(a, b),
         :ok <- validate_int32_range(a, b) do
      result =
        case Cache.get(a, b) do
          {:ok, cached} -> cached
          :miss -> Cache.put(a, b, MathService.add(a, b))
        end

      History.add_entry(a, b, result)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{result: result}))
    else
      :not_integers ->
        send_bad_request(conn, "Request body must contain integer fields 'a' and 'b'.")

      :out_of_range ->
        send_bad_request(
          conn,
          "Fields 'a' and 'b' must be 32-bit integers (#{@int32_min} to #{@int32_max})."
        )

      _ ->
        send_bad_request(conn, "Request body must contain integer fields 'a' and 'b'.")
    end
  end

  post "/api/calc" do
    with %{"op" => op, "a" => a, "b" => b} <- conn.body_params,
         :ok <- validate_integers(a, b),
         {:ok, module} <- find_operation(op),
         {:ok, result} <- module.execute(a, b) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{result: result}))
    else
      {:error, :unknown_op} ->
        ops = Operation.all() |> Map.keys() |> Enum.sort() |> Enum.join(", ")
        send_bad_request(conn, "Unknown operation. Supported: #{ops}.")

      {:error, reason} ->
        send_bad_request(conn, reason)

      :not_integers ->
        send_bad_request(conn, "Fields 'a' and 'b' must be integers.")

      _ ->
        send_bad_request(conn, "Request body must contain 'op', 'a', and 'b' fields.")
    end
  end

  post "/api/batch" do
    with pairs when is_list(pairs) <- conn.body_params["pairs"],
         :ok <- validate_pairs(pairs) do
      int_pairs = Enum.map(pairs, fn %{"a" => a, "b" => b} -> {a, b} end)

      results =
        Parallel.add_many(int_pairs)
        |> Enum.map(fn {a, b, r} -> %{a: a, b: b, result: r} end)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{results: results}))
    else
      _ ->
        send_bad_request(
          conn,
          "Request body must contain a 'pairs' array of {\"a\", \"b\"} integer objects."
        )
    end
  end

  get "/api/history" do
    entries =
      History.all()
      |> Enum.map(fn %{a: a, b: b, result: r, at: at} ->
        %{a: a, b: b, result: r, at: DateTime.to_iso8601(at)}
      end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{history: entries}))
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
  defp find_operation(op) do
    case Operation.find(op) do
      nil -> {:error, :unknown_op}
      mod -> {:ok, mod}
    end
  end

  @doc false
  defp validate_pairs(pairs) do
    if Enum.all?(pairs, &valid_pair?/1), do: :ok, else: :invalid_pairs
  end

  @doc false
  defp valid_pair?(%{"a" => a, "b" => b}) when is_integer(a) and is_integer(b), do: true
  defp valid_pair?(_), do: false

  @doc false
  defp validate_integers(a, b) when is_integer(a) and is_integer(b), do: :ok
  defp validate_integers(_, _), do: :not_integers

  @doc false
  defp validate_int32_range(a, b)
       when a >= @int32_min and a <= @int32_max and b >= @int32_min and b <= @int32_max,
       do: :ok

  defp validate_int32_range(_, _), do: :out_of_range

  @doc false
  defp send_bad_request(conn, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{error: message}))
  end

  @doc false
  defp ensure_json_headers(%Plug.Conn{request_path: path} = conn, _opts)
       when path in @json_api_paths do
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

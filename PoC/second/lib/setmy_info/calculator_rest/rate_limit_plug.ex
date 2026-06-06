defmodule SetmyInfo.CalculatorRest.RateLimitPlug do
  @moduledoc """
  Plug that enforces per-IP rate limits on `/api/*` endpoints.

  Requests are checked through `SetmyInfo.CalculatorRest.RateLimiter`.
  When the limit is exceeded the plug returns HTTP 429 with a
  `Retry-After: 60` header and halts the connection.

  Static files and other non-API paths are exempt from rate limiting.
  """

  import Plug.Conn

  alias SetmyInfo.CalculatorRest.RateLimiter

  @retry_after "60"

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    if String.starts_with?(conn.request_path, "/api/") do
      check_and_maybe_limit(conn)
    else
      conn
    end
  end

  defp check_and_maybe_limit(conn) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    case RateLimiter.check_rate(ip) do
      :ok ->
        conn

      {:error, :rate_limited} ->
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("retry-after", @retry_after)
        |> send_resp(429, Jason.encode!(%{error: "Rate limit exceeded. Retry after 60 seconds."}))
        |> halt()
    end
  end
end

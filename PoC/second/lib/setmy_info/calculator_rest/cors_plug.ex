defmodule SetmyInfo.CalculatorRest.CorsPlug do
  @moduledoc """
  Plug that adds CORS response headers and handles OPTIONS preflight requests.

  All origins are allowed (`*`) because this is a public API demo.
  For production, replace `*` with a specific origin allow-list.

  ## CSRF note

  CSRF is naturally mitigated for this API because:
  - Every state-changing endpoint requires `Content-Type: application/json`.
  - Browsers cannot send that content type cross-origin without triggering a
    CORS preflight first, so a malicious page cannot forge a request unless
    the preflight is explicitly approved here.

  The `ensure_json_headers` check in the router provides this guarantee.
  """

  import Plug.Conn

  @allowed_origin "*"
  @allowed_methods "GET, POST, OPTIONS"
  @allowed_headers "Content-Type, Accept, Authorization"
  @max_age "3600"

  @doc false
  def init(opts), do: opts

  @doc false
  def call(%Plug.Conn{method: "OPTIONS"} = conn, _opts) do
    conn
    |> put_cors_headers()
    |> put_resp_header("access-control-max-age", @max_age)
    |> send_resp(204, "")
    |> halt()
  end

  def call(conn, _opts), do: put_cors_headers(conn)

  defp put_cors_headers(conn) do
    conn
    |> put_resp_header("access-control-allow-origin", @allowed_origin)
    |> put_resp_header("access-control-allow-methods", @allowed_methods)
    |> put_resp_header("access-control-allow-headers", @allowed_headers)
  end
end

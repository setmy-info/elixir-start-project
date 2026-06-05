import Config

config :graphql_api,
  port: 4000

# ── Logger base configuration ─────────────────────────────────────────────────
# Format mirrors the Spring Boot logback UTC pattern:
#   date time [level]pad [node] metadata... - message
#
# $date        yyyy-mm-dd
# $time        HH:MM:SS.mmm  (UTC when utc_log: true)
# $level       debug | info | warning | error
#     spaces to right-align all level names to 7 chars
# $node        Erlang node name (service identity)
# $metadata    key=value pairs for all keys listed below
# $message     log message body
#
# Metadata keys — populated automatically by Plug.RequestId and the BEAM:
#   pid         Erlang process ID  (≈ Java thread)
#   module      calling module     (≈ %logger)
#   function    calling function
#   line        source line number
#   request_id  injected by Plug.RequestId  (≈ requestId MDC)
#   trace_id    injected by tracing library  (≈ traceId MDC)
#   span_id     injected by tracing library  (≈ spanId MDC)
config :logger,
  level: :info

config :logger, :console,
  format: "$date $time [$level] [$node] $metadata- $message\n",
  metadata: [:pid, :module, :function, :line, :request_id, :trace_id, :span_id]

# Mix defaults to :dev when no MIX_ENV is set.
# Map :dev → :local so a plain `mix` on a developer machine uses local.exs.
# Set MIX_ENV=dev explicitly to target the shared development server config.
effective_env = if config_env() == :dev, do: :local, else: config_env()
import_config "#{effective_env}.exs"

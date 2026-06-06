import Config

# Format mirrors the Spring Boot logback UTC pattern used in PoC/first:
#   $date $time [$level] [$node] $metadata- $message
#
# $date        yyyy-mm-dd
# $time        HH:MM:SS.mmm  (UTC when utc_log: true)
# $level       debug | info | warning | error
# $node        Erlang node name (service identity)
# $metadata    key=value pairs for the keys listed below
# $message     log message body
#
# Metadata keys populated automatically by the BEAM and Plug.RequestId:
#   pid         Erlang process ID  (≈ Java thread)
#   module      calling module     (≈ %logger)
#   function    calling function
#   line        source line number
#   request_id  injected by Plug.RequestId
#   trace_id    injected by tracing library
#   span_id     injected by tracing library
config :logger, :console,
  format: "$date $time [$level] [$node] $metadata- $message\n",
  metadata: [:pid, :module, :function, :line, :request_id, :trace_id, :span_id]

config :calculator_app,
  log_format: "$date $time [$level] [$node] $metadata- $message\n",
  log_metadata: [:pid, :module, :request_id],
  log_rotate_max_bytes: 1_048_576,
  log_rotate_keep: 5

import_config "#{config_env()}.exs"

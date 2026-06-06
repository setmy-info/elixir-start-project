import Config

log_format = "$date $time [$level] [$node] $metadata- $message\n"
log_metadata = [:pid, :module, :function, :line, :request_id, :trace_id, :span_id]
log_rotate_max_bytes = 1_048_576
log_rotate_keep = 5

log_dir = System.get_env("CALCULATOR_LOG_DIR", "log")
log_file = System.get_env("CALCULATOR_LOG_FILE", "calculator_app.log")
log_path = Path.join(log_dir, log_file)

log_level =
  case System.get_env("CALCULATOR_LOG_LEVEL", "info") |> String.downcase() do
    "debug" -> :debug
    "info" -> :info
    "warning" -> :warning
    "error" -> :error
    "critical" -> :critical
    _ -> :info
  end

port =
  if config_env() == :live do
    "PORT"
    |> System.fetch_env!()
    |> String.to_integer()
  else
    "PORT"
    |> System.get_env("4000")
    |> String.to_integer()
  end

server_enabled =
  System.get_env("CALCULATOR_SERVER", "false") == "true" or
    System.get_env("PHX_SERVER") in ["1", "true"]

config :calculator_app,
  server: server_enabled,
  rest_port: port,
  log_dir: log_dir,
  log_file: log_file

config :logger, :console,
  format: log_format,
  metadata: log_metadata

config :logger, :calculator_app_log,
  path: log_path,
  format: log_format,
  metadata: log_metadata,
  level: log_level,
  rotate: %{
    max_bytes: log_rotate_max_bytes,
    keep: log_rotate_keep
  }

# Live: refine console format to include Kubernetes pod identity.
# Set via the downward API:
#   env:
#     - name: POD_NAMESPACE
#       valueFrom: {fieldRef: {fieldPath: metadata.namespace}}
#     - name: POD_NAME
#       valueFrom: {fieldRef: {fieldPath: metadata.name}}
if config_env() == :live do
  pod_namespace = System.get_env("POD_NAMESPACE", "unknown")
  pod_name = System.get_env("POD_NAME", "unknown")

  config :logger, :console,
    format: "$date $timeZ [#{pod_namespace}/#{pod_name}] [$level] [$node] $metadata- $message\n",
    metadata: [:pid, :module, :request_id, :trace_id, :span_id]
end

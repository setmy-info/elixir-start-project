import Config

log_format = "$time $metadata[$level] $message\n"
log_metadata = [:request_id]
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

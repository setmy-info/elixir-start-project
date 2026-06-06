import Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:duration_ms, :method, :path, :request_id, :status]

config :calculator_app,
  log_format: "$time $metadata[$level] $message\n",
  log_metadata: [:request_id],
  log_rotate_max_bytes: 1_048_576,
  log_rotate_keep: 5

import_config "#{config_env()}.exs"

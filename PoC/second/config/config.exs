import Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :calculator_app,
  log_format: "$time $metadata[$level] $message\n",
  log_metadata: [:request_id],
  log_rotate_max_bytes: 1_048_576,
  log_rotate_keep: 5

import_config "#{config_env()}.exs"

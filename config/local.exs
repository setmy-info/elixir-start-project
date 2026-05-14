import Config

# Local developer machine — HTTP on 4000, DB optional.
config :graphql_api,
  port: 4000

# Verbose logging for local development: debug level, all metadata fields.
config :logger,
  level: :debug

config :logger, :console,
  format: "$date $time [$level] [$node] $metadata- $message\n",
  metadata: [:pid, :module, :function, :line, :request_id, :trace_id, :span_id]

# Uncomment and adjust to enable the database locally:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "elixir_start_local",
#   pool_size: 10

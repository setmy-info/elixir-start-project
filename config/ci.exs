import Config

# CI environment — no HTTP server, fixed port, DB sandbox when enabled.
config :graphql_api,
  start_http: false,
  port: 4002

# Keep CI output clean — only warnings and errors.
# request_id included so failed-request correlations remain traceable in CI logs.
config :logger,
  level: :warning

config :logger, :console,
  format: "$time [$level] $metadata- $message\n",
  metadata: [:module, :line, :request_id]

# Uncomment to run CI tests against a real database:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "elixir_start_ci",
#   pool: Ecto.Adapters.SQL.Sandbox

config :core_logic, SetmyInfo.CoreLogic.Repo,
  database: "/tmp/elixir_start_ci.db",
  pool_size: 1

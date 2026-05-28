import Config

# Disable HTTP server startup during tests
config :graphql_api,
  start_http: false,
  port: 4001

# Suppress info/debug noise during test runs — only warnings and errors appear.
# Tests that need to assert on log output should use ExUnit.CaptureLog.
config :logger,
  level: :warning

config :logger, :console,
  format: "$time [$level] $metadata- $message\n",
  metadata: [:module, :line, :request_id]

# Uncomment to run tests against a real database:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "elixir_start_test",
#   pool: Ecto.Adapters.SQL.Sandbox

config :core_logic, SetmyInfo.CoreLogic.Repo,
  database: "/tmp/elixir_start_test.db",
  pool_size: 1

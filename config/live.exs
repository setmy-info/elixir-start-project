import Config

# Live (production) environment — read port from system environment.
config :graphql_api,
  port: String.to_integer(System.get_env("PORT") || "4000")

# UTC timestamps, info level — runtime.exs overrides the format to embed
# POD_NAMESPACE and POD_NAME once the environment is available at startup.
config :logger,
  level: :info,
  utc_log: true

config :logger, :console,
  format: "$date $time UTC [$level] [$node] $metadata- $message\n",
  metadata: [:pid, :module, :request_id, :trace_id, :span_id]

# Configure via environment variables at runtime:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   url: System.get_env("DATABASE_URL"),
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

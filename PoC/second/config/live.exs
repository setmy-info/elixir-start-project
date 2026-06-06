import Config

# UTC timestamps, info level — runtime.exs refines the format to embed
# POD_NAMESPACE and POD_NAME once the environment is available at startup.
# $timeZ appends a literal "Z" after $time so the output matches Spring Boot's
# "2026-06-06 20:22:41.038Z" format instead of "20:22:41.038 UTC".
config :logger,
  level: :info,
  utc_log: true

config :logger, :console,
  format: "$date $timeZ [$level] [$node] $metadata- $message\n",
  metadata: [:pid, :module, :request_id, :trace_id, :span_id]

# Configure via DATABASE_PATH env var or fall back to a local file.
# config :calculator_app, SetmyInfo.Ecto.Repo,
#   database: System.get_env("DATABASE_PATH", "calculator_app.db")

import Config

config :logger, level: :debug

config :logger, :console,
  format: "$date $time [$level] [$node] $metadata- $message\n",
  metadata: [:pid, :module, :function, :line, :request_id, :trace_id, :span_id]

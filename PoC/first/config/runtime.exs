import Config

# runtime.exs is evaluated when the application starts (not at compile time),
# so System.get_env/2 reads the real Kubernetes downward-API values.
#
# Kubernetes deployment should set these via the downward API:
#   env:
#     - name: POD_NAMESPACE
#       valueFrom: { fieldRef: { fieldPath: metadata.namespace } }
#     - name: POD_NAME
#       valueFrom: { fieldRef: { fieldPath: metadata.name } }
if config_env() == :live do
  pod_namespace = System.get_env("POD_NAMESPACE", "unknown")
  pod_name = System.get_env("POD_NAME", "unknown")

  config :logger, :console,
    format:
      "$date $time UTC [#{pod_namespace}/#{pod_name}] [$level] [$node] $metadata- $message\n",
    metadata: [:pid, :module, :request_id, :trace_id, :span_id]
end

%Muzak.Config{
  # Only mutate production source code in unit-tested apps — not lessons or integration tests.
  # This mirrors Maven's "mutation testing on src/main/java" convention.
  files: [
    "apps/core_logic/lib/**/*.ex",
    "apps/runtime_engine/lib/**/*.ex",
    "apps/graphql_api/lib/**/*.ex",
    "apps/cli/lib/**/*.ex",
    "apps/wasm/lib/**/*.ex"
  ],
  formatters: [Muzak.Formatters.Simple]
}

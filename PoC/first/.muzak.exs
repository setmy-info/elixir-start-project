%{
  default: [
    files: [
      "apps/core_logic/lib/**/*.ex",
      "apps/runtime_engine/lib/**/*.ex",
      "apps/graphql_api/lib/**/*.ex",
      "apps/cli/lib/**/*.ex",
      "apps/wasm/lib/**/*.ex"
    ],
    formatters: [Muzak.Formatters.Simple]
  ]
}

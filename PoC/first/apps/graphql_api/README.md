# setmy_info_graphql_api

GraphQL API layer built with Absinthe + Plug + Cowboy, backed by `SetmyInfo.RuntimeEngine`.

Part of the [elixir-start-project](https://github.com/setmy-info/elixir-start-project) umbrella.

## Installation

```elixir
def deps do
  [
    {:setmy_info_graphql_api, "~> 0.1"}
  ]
end
```

## Features

- **Absinthe schema** — `add` and `multiply` queries dispatched through `RuntimeEngine`
- **Plug + Cowboy HTTP server** — starts on port 4000 by default
- **GraphiQL IDE** — available at `http://localhost:4000/graphql` in a browser

## Running

```sh
mix run --no-halt
```

```sh
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ add(a: 2, b: 3) }"}' | jq .
# => {"data":{"add":5}}
```

## License

MIT — see [LICENSE](LICENSE).

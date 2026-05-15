defmodule WhiteBreadConfig do
  use WhiteBread.SuiteConfiguration

  suite name:          "GraphQL API E2E",
        context:       GraphqlApiContext,
        feature_paths: ["features/"]
end

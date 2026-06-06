defmodule SetmyInfo.CalculatorRest.Swagger do
  @moduledoc """
  Generates the OpenAPI 3.2 description for the REST interface.

  All paths, schemas, and response codes are defined here as plain Elixir
  maps and encoded to JSON on demand.  Swagger UI is served at `/swagger`,
  the raw spec at `/swagger.json` and `/openapi.json`.
  """

  @doc "Returns the full OpenAPI spec as an Elixir map."
  def spec do
    %{
      openapi: "3.2.0",
      info: %{
        title: "Calculator REST API",
        version: "2.0",
        description:
          "Shared calculator HTTP server for REST, GraphQL, Swagger, and static web content.",
        contact: %{
          name: "Imre Tabur",
          url: "https://github.com/setmy-info/elixir-start-project"
        },
        license: %{
          name: "MIT",
          url: "https://opensource.org/licenses/MIT"
        }
      },
      servers: [
        %{url: "http://localhost:4000", description: "Local development server"}
      ],
      paths: %{
        "/api/add" => %{
          post: %{
            operationId: "addIntegers",
            summary: "Add two int32 integers",
            description:
              "Returns the sum of `a` and `b`. Both inputs must be 32-bit integers. " <>
                "The result is returned as a 64-bit integer to accommodate the maximum sum.",
            tags: ["calculator"],
            requestBody: req_body("AddRequest"),
            responses:
              json_responses(%{
                "200" => {"Successful addition", "AddResponse"},
                "400" =>
                  {"Invalid request body (missing or non-integer fields)", "ErrorResponse"},
                "406" => {"Accept header does not allow application/json", "ErrorResponse"},
                "415" => {"Content-Type is not application/json", "ErrorResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          }
        },
        "/api/calc" => %{
          post: %{
            operationId: "calculate",
            summary: "Generic arithmetic via named operation",
            description:
              "Dispatches to one of the pluggable `Operation` modules: " <>
                "`add`, `subtract`, `multiply`, `divide`. " <>
                "Division by zero returns HTTP 400.",
            tags: ["calculator"],
            requestBody: req_body("CalcRequest"),
            responses:
              json_responses(%{
                "200" => {"Operation result", "CalcResponse"},
                "400" =>
                  {"Unknown operation, division by zero, or invalid fields", "ErrorResponse"},
                "406" => {"Accept header does not allow application/json", "ErrorResponse"},
                "415" => {"Content-Type is not application/json", "ErrorResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          }
        },
        "/api/batch" => %{
          post: %{
            operationId: "batchAdd",
            summary: "Add many integer pairs concurrently",
            description:
              "Accepts an array of `{a, b}` pairs and returns their sums computed " <>
                "in parallel via `Task.async_stream`. Results are in input order.",
            tags: ["calculator"],
            requestBody: req_body("BatchRequest"),
            responses:
              json_responses(%{
                "200" => {"All pair results", "BatchResponse"},
                "400" => {"Missing or malformed pairs array", "ErrorResponse"},
                "406" => {"Accept header does not allow application/json", "ErrorResponse"},
                "415" => {"Content-Type is not application/json", "ErrorResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          }
        },
        "/api/history" => %{
          get: %{
            operationId: "getHistory",
            summary: "Return recent calculation history",
            description:
              "Returns the last up to 100 operations recorded by the `History` GenServer. " <>
                "Returns an empty list if the GenServer is not running.",
            tags: ["history"],
            responses:
              json_responses(%{
                "200" => {"History entries (oldest first)", "HistoryResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          }
        },
        "/api/total" => %{
          get: %{
            operationId: "getRunningTotal",
            summary: "Return the current running total",
            description:
              "Returns the accumulated sum managed by the `RunningTotal` Agent. " <>
                "Returns `0` if the Agent is not running.",
            tags: ["total"],
            responses:
              json_responses(%{
                "200" => {"Current running total", "TotalResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          },
          post: %{
            operationId: "addToTotal",
            summary: "Add a value to the running total",
            description: "Adds `value` to the running total and returns the new total.",
            tags: ["total"],
            requestBody: req_body("AddToTotalRequest"),
            responses:
              json_responses(%{
                "200" => {"Updated running total", "TotalResponse"},
                "400" => {"Missing or non-integer value field", "ErrorResponse"},
                "503" => {"RunningTotal Agent not available", "ErrorResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          },
          delete: %{
            operationId: "resetTotal",
            summary: "Reset the running total to 0",
            description:
              "Resets the `RunningTotal` Agent to zero. " <>
                "Succeeds (returns 0) even if the Agent is not running.",
            tags: ["total"],
            responses:
              json_responses(%{
                "200" => {"Running total after reset (always 0)", "TotalResponse"},
                "429" => {"Rate limit exceeded", "ErrorResponse"},
                "500" => {"Unexpected server error", "ErrorResponse"}
              })
          }
        }
      },
      components: %{
        schemas: %{
          AddRequest: %{
            type: "object",
            required: ["a", "b"],
            properties: %{
              a: %{type: "integer", format: "int32", example: 2},
              b: %{type: "integer", format: "int32", example: 3}
            },
            example: %{a: 2, b: 3}
          },
          AddResponse: %{
            type: "object",
            required: ["result", "at"],
            properties: %{
              result: %{type: "integer", format: "int64", example: 5},
              at: %{type: "string", format: "date-time", example: "2026-01-01T12:00:00.123Z"}
            },
            example: %{result: 5, at: "2026-01-01T12:00:00.123Z"}
          },
          CalcRequest: %{
            type: "object",
            required: ["op", "a", "b"],
            properties: %{
              op: %{
                type: "string",
                enum: ["add", "subtract", "multiply", "divide"],
                example: "add"
              },
              a: %{type: "integer", format: "int32", example: 10},
              b: %{type: "integer", format: "int32", example: 3}
            },
            example: %{op: "add", a: 10, b: 3}
          },
          CalcResponse: %{
            type: "object",
            required: ["result", "at"],
            properties: %{
              result: %{type: "number", example: 13},
              at: %{type: "string", format: "date-time", example: "2026-01-01T12:00:00.123Z"}
            },
            example: %{result: 13, at: "2026-01-01T12:00:00.123Z"}
          },
          BatchRequest: %{
            type: "object",
            required: ["pairs"],
            properties: %{
              pairs: %{
                type: "array",
                items: %{"$ref" => "#/components/schemas/Pair"},
                example: [%{a: 1, b: 2}, %{a: 3, b: 4}]
              }
            },
            example: %{pairs: [%{a: 1, b: 2}, %{a: 3, b: 4}]}
          },
          Pair: %{
            type: "object",
            required: ["a", "b"],
            properties: %{
              a: %{type: "integer", format: "int32", example: 1},
              b: %{type: "integer", format: "int32", example: 2}
            },
            example: %{a: 1, b: 2}
          },
          BatchResponse: %{
            type: "object",
            required: ["results", "at"],
            properties: %{
              results: %{
                type: "array",
                items: %{"$ref" => "#/components/schemas/BatchResultItem"}
              },
              at: %{type: "string", format: "date-time", example: "2026-01-01T12:00:00.123Z"}
            },
            example: %{
              results: [%{a: 1, b: 2, result: 3, at: "2026-01-01T12:00:00.123Z"}],
              at: "2026-01-01T12:00:00.123Z"
            }
          },
          BatchResultItem: %{
            type: "object",
            required: ["a", "b", "result", "at"],
            properties: %{
              a: %{type: "integer", format: "int32", example: 1},
              b: %{type: "integer", format: "int32", example: 2},
              result: %{type: "integer", format: "int64", example: 3},
              at: %{type: "string", format: "date-time", example: "2026-01-01T12:00:00.123Z"}
            },
            example: %{a: 1, b: 2, result: 3, at: "2026-01-01T12:00:00.123Z"}
          },
          HistoryResponse: %{
            type: "object",
            required: ["history"],
            properties: %{
              history: %{
                type: "array",
                items: %{"$ref" => "#/components/schemas/HistoryEntry"}
              }
            },
            example: %{history: []}
          },
          HistoryEntry: %{
            type: "object",
            required: ["a", "b", "result", "at"],
            properties: %{
              a: %{type: "integer", format: "int32", example: 2},
              b: %{type: "integer", format: "int32", example: 3},
              result: %{type: "integer", format: "int64", example: 5},
              at: %{type: "string", format: "date-time", example: "2026-01-01T12:00:00.123Z"}
            },
            example: %{a: 2, b: 3, result: 5, at: "2026-01-01T12:00:00.123Z"}
          },
          TotalResponse: %{
            type: "object",
            required: ["total", "at"],
            properties: %{
              total: %{type: "integer", format: "int64", example: 10},
              at: %{type: "string", format: "date-time", example: "2026-01-01T12:00:00.123Z"}
            },
            example: %{total: 10, at: "2026-01-01T12:00:00.123Z"}
          },
          AddToTotalRequest: %{
            type: "object",
            required: ["value"],
            properties: %{
              value: %{type: "integer", format: "int32", example: 5}
            },
            example: %{value: 5}
          },
          ErrorResponse: %{
            type: "object",
            required: ["error"],
            properties: %{
              error: %{
                type: "string",
                example: "Request body must contain integer fields 'a' and 'b'."
              }
            },
            example: %{error: "Request body must contain integer fields 'a' and 'b'."}
          }
        }
      }
    }
  end

  @doc "Returns the Swagger document encoded as JSON."
  def json, do: Jason.encode!(spec())

  @doc "Returns a small Swagger UI page bound to the generated JSON spec."
  def ui_html do
    """
    <!DOCTYPE html>
    <html lang=\"en\">
      <head>
        <meta charset=\"UTF-8\" />
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
        <title>Calculator REST Swagger UI</title>
        <link rel=\"stylesheet\" href=\"https://unpkg.com/swagger-ui-dist@5/swagger-ui.css\" />
      </head>
      <body>
        <div id=\"swagger-ui\"></div>
        <script src=\"https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js\"></script>
        <script>
          window.onload = function () {
            window.ui = SwaggerUIBundle({
              url: '/openapi.json',
              dom_id: '#swagger-ui'
            });
          };
        </script>
      </body>
    </html>
    """
  end

  # ── Private helpers ────────────────────────────────────────────────────────

  defp req_body(schema_ref) do
    %{
      required: true,
      content: %{
        "application/json" => %{
          schema: %{"$ref" => "#/components/schemas/#{schema_ref}"}
        }
      }
    }
  end

  defp json_responses(codes) do
    Map.new(codes, fn {status, {description, schema_ref}} ->
      {status,
       %{
         description: description,
         content: %{
           "application/json" => %{
             schema: %{"$ref" => "#/components/schemas/#{schema_ref}"}
           }
         }
       }}
    end)
  end
end

defmodule SetmyInfo.CalculatorRest.Swagger do
  @moduledoc """
  Generates the OpenAPI/Swagger description for the REST interface.
  """

  @doc """
  Returns the Swagger document as an Elixir map.
  """
  def spec do
    %{
      openapi: "3.2.0",
      info: %{
        title: "Calculator REST API",
        version: "2.0",
        description:
          "Shared calculator HTTP server for REST, GraphQL, Swagger, and static web content."
      },
      paths: %{
        "/api/add" => %{
          post: %{
            summary: "Add two integers",
            description:
              "Accepts JSON input with integer fields `a` and `b` and returns the computed sum.",
            tags: ["calculator"],
            requestBody: %{
              required: true,
              content: %{
                "application/json" => %{
                  schema: %{"$ref" => "#/components/schemas/AddRequest"}
                }
              }
            },
            responses: %{
              "200" => %{
                description: "Successful response",
                content: %{
                  "application/json" => %{
                    schema: %{"$ref" => "#/components/schemas/AddResponse"}
                  }
                }
              },
              "400" => %{
                description: "Invalid request body",
                content: %{
                  "application/json" => %{
                    schema: %{"$ref" => "#/components/schemas/ErrorResponse"}
                  }
                }
              },
              "406" => %{
                description: "Accept header does not allow JSON",
                content: %{
                  "application/json" => %{
                    schema: %{"$ref" => "#/components/schemas/ErrorResponse"}
                  }
                }
              },
              "415" => %{
                description: "Content-Type is not JSON",
                content: %{
                  "application/json" => %{
                    schema: %{"$ref" => "#/components/schemas/ErrorResponse"}
                  }
                }
              }
            }
          }
        }
      },
      components: %{
        schemas: %{
          AddRequest: %{
            type: "object",
            required: ["a", "b"],
            properties: %{
              a: %{type: "integer", format: "int32"},
              b: %{type: "integer", format: "int32"}
            }
          },
          AddResponse: %{
            type: "object",
            required: ["result"],
            properties: %{
              result: %{type: "integer", format: "int32"}
            }
          },
          ErrorResponse: %{
            type: "object",
            required: ["error"],
            properties: %{
              error: %{type: "string"}
            }
          }
        }
      }
    }
  end

  @doc """
  Returns the Swagger document encoded as JSON.
  """
  def json, do: Jason.encode!(spec())

  @doc """
  Returns a small Swagger UI page bound to the generated JSON spec.
  """
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
              url: '/swagger.json',
              dom_id: '#swagger-ui'
            });
          };
        </script>
      </body>
    </html>
    """
  end
end

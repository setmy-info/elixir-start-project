Feature: GraphQL API arithmetic operations
  As a client using the GraphQL API
  I want to perform arithmetic operations via HTTP
  So that I can compute results through the running server

  Background:
    Given the GraphQL server is running

  Scenario: Adding two numbers returns their sum
    When I call add with a=2 and b=3
    Then the response should have add equal to 5

  Scenario: Multiplying two numbers returns their product
    When I call multiply with a=3 and b=4
    Then the response should have multiply equal to 12

  Scenario: Adding a negative and a positive number
    When I call add with a=-4 and b=10
    Then the response should have add equal to 6

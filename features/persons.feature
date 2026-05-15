Feature: Person management via GraphQL API
  As a client using the GraphQL API
  I want to insert and retrieve persons via HTTP
  So that I can persist and verify person data through the running server

  Background:
    Given the GraphQL server is running

  Scenario: Insert multiple persons and verify they all exist
    When I create a person with firstName "John" and lastName "Doe"
    When I create a person with firstName "Jane" and lastName "Smith"
    When I create a person with firstName "Alice" and lastName "Wonder"
    Then a person with firstName "John" and lastName "Doe" exists
    And a person with firstName "Jane" and lastName "Smith" exists
    And a person with firstName "Alice" and lastName "Wonder" exists

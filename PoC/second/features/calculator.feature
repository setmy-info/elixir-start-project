Feature: Calculator REST API arithmetic operations
  As a client using the Calculator REST API
  I want to perform arithmetic operations via HTTP
  So that I can compute results through the running server

  Background:
    Given the calculator REST server is running

  Scenario: Adding two positive numbers returns their sum
    When I POST add with a=2 and b=3
    Then the response should have result equal to 5

  Scenario: Adding with zero returns the same number
    When I POST add with a=0 and b=7
    Then the response should have result equal to 7

  Scenario: Adding negative numbers
    When I POST add with a=-4 and b=-6
    Then the response should have result equal to -10

  Scenario: Adding a negative and a positive number
    When I POST add with a=-4 and b=10
    Then the response should have result equal to 6

  Scenario: Adding large integers
    When I POST add with a=1000000 and b=2500000
    Then the response should have result equal to 3500000

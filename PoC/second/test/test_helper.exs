ExUnit.start()

# Available ExUnit tags for selective test execution:
#
#   @moduletag :unit          – pure unit tests (test/unit/)
#   @moduletag :integration   – integration tests (test/integration/)
#   @moduletag :e2e           – end-to-end CLI tests (test/e2e/)
#   @moduletag :gherkin       – BDD/Gherkin tests (test/gherkin/)
#   @tag       :property      – StreamData property-based tests
#   @tag       :concurrent    – concurrent/race-condition tests
#   @tag       :slow          – tests with elevated run time
#
# Examples:
#   mix test --only property
#   mix test --exclude slow
#   mix test --exclude integration --exclude e2e

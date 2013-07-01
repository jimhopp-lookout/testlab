Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Scenario: TestLab help
    When I get help for "tl"
    Then the exit status should be 0

  Scenario: TestLab status
    When I get status for "tl"
    Then the exit status should be 0

  Scenario: TestLab build
    When I trigger a lab build with "tl"
    Then the exit status should be 0

  Scenario: TestLab export
    When I trigger an export of containers with "tl"
    Then the exit status should be 0

  Scenario: TestLab import
    When I trigger an import of containers with "tl"
    Then the exit status should be 0


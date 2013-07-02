Feature: TestLab command-line

  Scenario: TestLab help
    When I get help for "tl"
    Then the exit status should be 0

  Scenario: TestLab status
    When I get status for "tl"
    Then the exit status should be 0

  Scenario: TestLab build from scratch
    When I trigger a lab build with "tl"
    Then the exit status should be 0

  Scenario: TestLab export
    When I trigger an export of containers with "tl"
    Then the exit status should be 0

  Scenario: TestLab import
    When I trigger an import of containers with "tl"
    Then the exit status should be 0

  Scenario: TestLab build after import
    When I trigger a lab build with "tl"
    Then the exit status should be 0

  Scenario: TestLab destroy
    When I trigger a lab destroy with "tl"
    Then the exit status should be 0

Feature: TestLab command-line

  Background: TestLab status
    When I get status for "tl"
    Then the exit status should be 0
    When I get node status for "tl"
    Then the exit status should be 0
    When I get network status for "tl"
    Then the exit status should be 0
    When I get container status for "tl"
    Then the exit status should be 0
    When I get container ssh-config for "tl"
    Then the exit status should be 0


  Scenario: TestLab help
    When I get help for "tl"
    Then the exit status should be 0


  Scenario: TestLab export
    When I trigger a lab build with "tl"
    Then the exit status should be 0
    When I trigger an export of containers with "tl"
    Then the exit status should be 0


  Scenario: TestLab import
    When I trigger an import of containers with "tl"
    Then the exit status should be 0
    When I trigger a lab build with "tl"
    Then the exit status should be 0


  Scenario: TestLab destroy
    When I trigger a lab destroy with "tl"
    Then the exit status should be 0

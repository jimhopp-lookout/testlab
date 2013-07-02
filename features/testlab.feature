Feature: TestLab command-line

  Background: TestLab status
    When I get status with "tl"
    Then the exit status should be 0
    When I get nodes status with "tl"
    Then the exit status should be 0
    When I get networks status with "tl"
    Then the exit status should be 0
    When I get containers status with "tl"
    Then the exit status should be 0
    When I get containers ssh-config with "tl"
    Then the exit status should be 0


  Scenario: TestLab help
    When I get help for "tl"
    Then the exit status should be 0


  Scenario: TestLab export
    When I build the lab with "tl"
    Then the exit status should be 0
    When I export containers with "tl"
    Then the exit status should be 0


  Scenario: TestLab import
    When I import containers with "tl"
    Then the exit status should be 0
    When I build the lab with "tl"
    Then the exit status should be 0


  Scenario: TestLab clone
    When I down the lab with "tl"
    Then the exit status should be 0
    When I build the lab with "tl"
    Then the exit status should be 0
    When I clone containers with "tl"
    Then the exit status should be 0
    When I build containers with "tl"
    Then the exit status should be 0
    When I clone containers with "tl"
    Then the exit status should be 0
    When I build containers with "tl"
    Then the exit status should be 0
    When I down containers with "tl"
    Then the exit status should be 0
    When I up containers with "tl"
    Then the exit status should be 0
    When I build containers with "tl"
    Then the exit status should be 0


  Scenario: TestLab destroy
    When I build the lab with "tl"
    Then the exit status should be 0
    When I destroy the lab with "tl"
    Then the exit status should be 0

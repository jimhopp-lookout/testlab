Feature: TestLab command-line

  Background: TestLab status
    When I get the status with "tl"
    Then the exit status should be 0
    When I get the nodes status with "tl"
    Then the exit status should be 0
    When I get the networks status with "tl"
    Then the exit status should be 0
    When I get the containers status with "tl"
    Then the exit status should be 0
    When I get the containers ssh-config with "tl"
    Then the exit status should be 0


  Scenario: TestLab help
    When I get help for "tl"
    Then the exit status should be 0


  Scenario: TestLab import
    When I down the lab with "tl"
    Then the exit status should be 0
    When I up the nodes with "tl"
    Then the exit status should be 0
    When I import the containers with "tl"
    Then the exit status should be 0
    When I build the lab with "tl"
    Then the exit status should be 0


  Scenario: TestLab clone
    When I down the lab with "tl"
    Then the exit status should be 0
    When I build the lab with "tl"
    Then the exit status should be 0
    When I clone the containers with "tl"
    Then the exit status should be 0
    When I build the containers with "tl"
    Then the exit status should be 0
    When I clone the containers with "tl"
    Then the exit status should be 0
    When I build the containers with "tl"
    Then the exit status should be 0
    When I down the containers with "tl"
    Then the exit status should be 0
    When I up the containers with "tl"
    Then the exit status should be 0
    When I build the containers with "tl"
    Then the exit status should be 0


  Scenario: TestLab destroy
    When I down the lab with "tl"
    Then the exit status should be 0
    When I destroy the lab with "tl"
    Then the exit status should be 0

#encoding: utf-8
Feature: Make sure we have the correct number of kubernetes nodes
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run these scenario and see the correct exit code and nodes output

  Scenario: Getting nodes
    When I run `kubectl --cluster=aws get nodes`
    Then the exit status should eventually be 0
    And the output should eventually match:
      """
      .*
      .*Ready
      .*Ready
      .*Ready
      """
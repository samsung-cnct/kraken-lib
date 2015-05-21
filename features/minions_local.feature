#encoding: utf-8
Feature: Make sure we have the correct number of kubernetes minions
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run this scenario and see the correct minions output
 
  Scenario: Getting minions
    When I run `kubectl --kubeconfig=/tmp/.kubeconfig get minions`
    Then the exit status should be 0
    And the output should eventually match:
      """
      .*
      .*Ready
      .*Ready
      """
#encoding: utf-8
Feature: Make sure we have the correct kubernetes services
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run these scenario and see the correct exit code and services output

  Scenario: Getting kube-system services
    When I kubectl system services
    Then the exit status should eventually be 0
    And the output should eventually match:
      """
      .*
      kube-dns.*
      kube-ui.*
      """

  Scenario: Getting default services
    When I kubectl services
    Then the exit status should eventually be 0
    And the output should eventually match:
      """
      .*
      heapster.*
      kubernetes.*
      prometheus.*
      """

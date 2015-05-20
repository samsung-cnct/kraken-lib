#encoding: utf-8
Feature: Make sure we have the correct number of kubernetes minions
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run this scenario and see the correct minions output
 
  Scenario: Getting minions
    When I run `kubectl --kubeconfig=../../kubernetes/local/.kubeconfig get -o yaml minions`
    Then the output should match:
      """
      apiVersion: v1beta3
      items:
      - apiVersion: v1beta3
        kind: Node
      .*
      - apiVersion: v1beta3
        kind: Node
      .*
      """
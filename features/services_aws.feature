#encoding: utf-8
Feature: Make sure we have the correct kubernetes services
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run these scenarios and see the correct exit code and services output
 
  Scenario: Getting connection
    When I run `kubectl --cluster=aws get services`
    Then the exit status should eventually be 0

  Scenario: Getting services
    When I run `kubectl --cluster=aws get services`
    And the output should eventually match:
      """
      .*
      kube-dns.*
      kubernetes.*
      kubernetes-ro.*
      monitoring-grafana.*
      monitoring-heapster.*
      monitoring-influxdb.*
      monitoring-influxdb-ui.*
      """
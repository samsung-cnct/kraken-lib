#encoding: utf-8
Feature: Make sure we have the correct kubernetes services
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run this scenario and see the correct services output
 
  Scenario: Getting services
    When I run `kubectl --cluster=aws get services`
    Then the exit status should be 0
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
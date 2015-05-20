#encoding: utf-8
Feature: Make sure we have the correct kubernetes services
  In order to verify that cluster came up correctly
  As kraken developer 
  I should be able to run this scenario and see the correct services output
 
  Scenario: Getting services
    When I run `kubectl --kubeconfig=../../kubernetes/local/.kubeconfig get -o yaml services`
    Then the output should match:
      """
      apiVersion: v1beta3
      items:
      - apiVersion: v1beta3
      .*
        metadata:
      .*
          name: kube-dns
      .*
      - apiVersion: v1beta3
      .*
        metadata:
      .*
          name: kubernetes
      .*
      - apiVersion: v1beta3
      .*
        metadata:
      .*
          name: kubernetes-ro
      .*
      - apiVersion: v1beta3
      .*
        metadata:
      .*
          name: monitoring-grafana
      .*
      - apiVersion: v1beta3
        .*
        metadata:
      .*
          name: monitoring-heapster
      .*
      - apiVersion: v1beta3
        .*
        metadata:
      .*
          name: monitoring-influxdb
      .*
      - apiVersion: v1beta3
        .*
        metadata:
      .*
          name: monitoring-influxdb-ui
      .*
      """
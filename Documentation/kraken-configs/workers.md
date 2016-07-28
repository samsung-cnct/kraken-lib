#Workers

#Configuration Example
```yaml
- workers:
  - pool-name: worker-pool-a
    kubernetes-config:
      labels:
        - name: role
          value: doesStuff
        - name: price
          value: high
      container-engine: docker
  - pool-name: worker-pool-b
    kubernetes-config:
      labels:
        - name: role
          value: doesOtherStuff
        - name: price
          value: medium
      container-engine: rkt
```
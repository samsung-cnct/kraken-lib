#Kraken AWS nodepool configuration

Provider - specific node configuration for AWS

#Sections

##type

AWS EC2 machine type. t2.micro, etc

##tags

Array of tags to apply to node. 'Name' is forced to value of resourcePrefix + pool name.

## Storage

Array of storage volumes 

### type

Storage volume type. root (only one supported), ebs or ephemeral

### volume

The type of volume. Can be "standard", "gp2", or "io1". Only supported by root and ebs volumes

### size

Size of volume in gigabytes. Only supported by root and ebs volumes.

### iops

The amount of provisioned IOPS. This must be set with a volume of "io1". Only supported by root and ebs volumes

###delete

Delete on termination of instance. Only supported by root and ebs volumes


###snapshotId

The Snapshot ID to mount. Only supported by ebs volumes

###encrypted

Enables EBS encryption on the volume. Cannot be used with snapshotId. Only supported by ebs volumes.


# Prototype
```yaml
nodepools:
  - 
    name: master
    ...
    configuration:
      type: m3.medium
      tags:
        -
          name: comments
          value: "bow down before your master"
      storage:
        -
          type: root
          volume: gp2
          size: 10
          delete: no
        - 
          type: ebs
          volume: io1
          size: 100
          iops: 5000
          delete: no
          snapshotId:
          encrypted: yes
        - 
          type: ephemeral
          deviceName: sdb
          virtualName: ephemeral0
```
Role Name
=========
kraken.containerconfig

Generates any units required for container runtime configuration from loaded yaml configuration

Requirements
------------

TBD

Role Variables
--------------

refer to repository docs

Dependencies
------------

must run after kraken.config

Example Playbook
----------------

Basic role call:

    ---
    - hosts: localhost
      roles:
        - { role: kraken.containerconfig }

License
-------

Apache 2.0

Author Information
------------------

Samsung CNCT

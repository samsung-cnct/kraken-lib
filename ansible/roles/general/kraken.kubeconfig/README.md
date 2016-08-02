Role Name
=========
kraken.kubeconfig

Generates kubernetes units from loaded yaml configuration

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
        - { role: kraken.kubeconfig }

License
-------

Apache 2.0

Author Information
------------------

Samsung CNCT

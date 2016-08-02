Role Name
=========

Sets a bunch of config facts from a loaded config yml

Requirements
------------

TBD

Role Variables
--------------

refer to repository docs

Dependencies
------------

TBD

Example Playbook
----------------

Basic role call:

    ---
    - hosts: localhost
      roles:
        - { role: kraken.config, config_file: "{{config_file}}" }

License
-------

Apache 2.0

Author Information
------------------

Samsung CNCT

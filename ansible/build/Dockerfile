FROM phusion/baseimage

ENV ANSIBLE_VERSION 2.0.0.2

RUN apt-get update && \
    apt-get install -y python python-dev python-pip ca-certificates git && \
    pip install ansible==${ANSIBLE_VERSION} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV ANSIBLE_CONFIG=/etc/ansible-config/ansible.cfg
COPY ansible.cfg $ANSIBLE_CONFIG

CMD ["/sbin/my_init"]

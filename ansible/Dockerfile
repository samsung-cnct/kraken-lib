FROM phusion/baseimage

RUN apt-get update && \
    apt-get install -y python python-dev python-pip ca-certificates&& \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install ansible
COPY ansible.cfg /etc/ansible/ansible.cfg

CMD ["/sbin/my_init"]
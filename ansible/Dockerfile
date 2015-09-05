FROM phusion/baseimage

RUN apt-get update && \
    apt-get install -y python python-dev python-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install ansible
RUN ansible-galaxy install defunctzombie.coreos-bootstrap
ADD iaas_provision.yaml /opt/ansible/iaas_provision.yaml
ADD roles/kubernetes /opt/ansible/roles/kubernetes
COPY ansible.cfg /etc/ansible/ansible.cfg

CMD ["/sbin/my_init"]
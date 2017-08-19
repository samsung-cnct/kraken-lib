FROM jenkinsci/jnlp-slave:3.7-1-alpine

USER root
ADD https://storage.googleapis.com/kubernetes-release/release/v1.7.4/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
USER jenkins

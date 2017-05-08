FROM buildpack-deps:jessie-scm
MAINTAINER Pat Christopher <patrick.c@samsung.com>

ENV GOLANG_DEB_VERSION=2:1.7~5~bpo8+1 \
    GOOGLE_CLOUD_SDK_VERSION=117.0.0 \
    KUBERNETES_VERSION=v1.3.2

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

USER root

# Install apt managed packages (python, ruby, golang, etc.)
ENV GOROOT=/usr/lib/go
RUN apt-get update \
    && apt-get install -y --force-yes \
      curl \
      unzip \
      jq \
      build-essential \
      libssl-dev \
      libffi-dev \
      git \
      python \
      python-dev \
      python-pip \
      vim \
      golang-doc=${GOLANG_DEB_VERSION} \
      golang-go=${GOLANG_DEB_VERSION} \
      golang-src=${GOLANG_DEB_VERSION} \
      rsync \
      dnsutils \
    && rm -rf /var/lib/apt/lists/*

# All python modules should be installed here if possible
COPY requirements.txt /opt/kraken-ci/containers/jenkins/
RUN pip install --upgrade pip \
  && pip install --requirement /opt/kraken-ci/containers/jenkins/requirements.txt

## Install Google Cloud SDK
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && tar xzf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && rm google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && google-cloud-sdk/install.sh --usage-reporting=false --path-update true --bash-completion true --rc-path ~/.bashrc

## Install gsutil
RUN mkdir -p /google-cloud-util/bin/

RUN wget https://storage.googleapis.com/pub/gsutil.tar.gz -O /google-cloud-util/gsutil.tar.gz && \
        tar -xzf /google-cloud-util/gsutil.tar.gz -C /google-cloud-util/bin && \
        rm /google-cloud-util/gsutil.tar.gz

ENV PATH=${PATH}:/google-cloud-util/bin/gsutil
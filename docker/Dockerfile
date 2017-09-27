FROM quay.io/samsung_cnct/k2-tools:latest

ARG K2_REPO=https://github.com/samsung-cnct/k2.git
ARG K2_BRANCH=master
ARG K2_SHA=""

RUN 	apk update && \
	     apk add git && \
	     git clone --branch $K2_BRANCH --depth 1 $K2_REPO /kraken && \
       if [ $K2_SHA != "" ]; then cd /kraken; git fetch $K2_REPO +refs/pull/*:refs/remotes/origin/pr/*; git checkout -f ${K2_SHA}; fi && \
       apk del git

WORKDIR "/kraken"
CMD ["./bin/up.sh"]

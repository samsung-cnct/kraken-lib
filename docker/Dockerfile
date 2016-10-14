FROM quay.io/samsung_cnct/k2-tools:latest

ARG K2_REPO=https://github.com/samsung-cnct/k2.git
ARG K2_BRANCH=master

RUN 	apk update && \
	apk add git && \
	git clone --branch $K2_BRANCH --depth 1 $K2_REPO /kraken && apk del git

WORKDIR "/kraken"
CMD ["./up.sh"]
FROM quay.io/samsung_cnct/k2-tools:v0.2

RUN 	apk update && \
	apk add git && \
	git clone --branch master --depth 1 https://github.com/samsung-cnct/kraken.git /kraken && apk del git

CMD	/kraken/docker/up.sh

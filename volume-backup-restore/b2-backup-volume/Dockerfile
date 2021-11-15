
FROM alpine
ARG MC_ARCH=linux-arm

RUN apk add pv
RUN apk add jq

RUN wget "https://dl.minio.io/client/mc/release/$MC_ARCH/mc"
RUN chmod +x mc
RUN cp mc /usr/local/bin/

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

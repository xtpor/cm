
FROM debian:buster-slim

RUN apt-get update -y && apt-get install -y wget
WORKDIR /download
RUN wget https://dl.gitea.io/gitea/1.15.2/gitea-1.15.2-linux-arm-6
RUN chmod +x gitea-1.15.2-linux-arm-6

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-armhf ./tini
RUN chmod +x tini

FROM debian:buster-slim

COPY --from=0 /download/gitea-1.15.2-linux-arm-6 /usr/local/bin/gitea
COPY --from=0 /download/tini /usr/local/bin/tini
ENTRYPOINT ["tini"]
CMD ["gitea"]
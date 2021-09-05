
FROM debian:buster-slim

RUN apt-get update -y && apt-get install -y gettext-base curl
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY Caddyfile.tpl /Caddyfile.tpl
ENTRYPOINT ["/docker-entrypoint.sh"]


FROM debian:buster-slim

RUN apt-get update -y && apt-get install -y git
RUN git clone https://github.com/Jermolene/TiddlyWiki5 --branch v5.1.23

FROM node:lts-buster

COPY --from=0 /TiddlyWiki5 /app/tiddlywiki5
RUN ln -s /app/tiddlywiki5/tiddlywiki.js /usr/local/bin/tiddlywiki

CMD ["tiddlywiki"]

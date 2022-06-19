
# duckdns-updater

This image checks the ip address of a duckdns domain every 5 minutes, updates it to match the public ip of the container if it does not match.

## Usage

```
docker run -e DOMAIN=<duckdns-domain> -e TOKEN=<duckdns-api-token> tintinho/duckdns-updater:1
```

## Build

```
docker buildx bake
```
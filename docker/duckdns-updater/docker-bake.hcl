group "default" {
  targets = ["duckdns-updater"]
}

target "duckdns-updater" {
  dockerfile = "Dockerfile"
  context = "."
  platforms = ["linux/amd64", "linux/arm/v7"]
  tags = ["tintinho/duckdns-updater:1"]
  output = ["type=registry"]
}
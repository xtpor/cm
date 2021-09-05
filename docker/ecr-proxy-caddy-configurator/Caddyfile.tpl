:80

reverse_proxy ${REGISTRY_URL} {
  header_up Host {upstream_hostport}
  header_up Authorization "Basic ${REGISTRY_BASIC_CREDENTIAL}"
}

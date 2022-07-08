function (name, domain, duckdnsApiToken) [
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: name,
      labels: {
        "app.kubernetes.io/name": name,
      },
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          "app.kubernetes.io/name": name,
        },
      },
      template: {
        metadata: {
          labels: {
            "app.kubernetes.io/name": name,
          },
        },
        spec: {
          containers: [
            {
              name: "main",
              image: "tintinho/duckdns-updater:1",
              env: [
                {
                  name: "DOMAIN",
                  value: domain,
                },
                {
                  name: "TOKEN",
                  valueFrom: {
                    secretKeyRef: {
                      name: name,
                      key: "duckdnsApiToken",
                    },
                  },
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: name,
    },
    stringData: {
      duckdnsApiToken: duckdnsApiToken,
    },
  },
]
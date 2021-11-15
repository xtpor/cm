function(name, pvcName) [
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
              image: "osixia/openldap:1.5.0",
              ports: [
                { name: "ldap", containerPort: 389 },
              ],
              env: [
                { name: "KEEP_EXISTING_CONFIG", value: "true" },
              ],
              volumeMounts: [
                { name: "data", mountPath: "/var/lib/ldap", subPath: "database" },
                { name: "data", mountPath: "/etc/ldap/slapd.d", subPath: "config" },
                { name: "data", mountPath: "/vol" },
              ],
            },
          ],
          volumes: [
            { name: "data", persistentVolumeClaim: { claimName: pvcName } },
          ],
        },
      },
    },
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: name,
    },
    spec: {
      selector: {
        "app.kubernetes.io/name": name,
      },
      ports: [
        { protocol: "TCP", port: 389, targetPort: 389, },
      ],
      type: "ClusterIP",
    },
  },
]

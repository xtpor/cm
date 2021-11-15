function(jobName="", pvcName="", config) [
  {
    apiVersion: "batch/v1",
    kind: "Job",
    metadata: {
      name: jobName,
    },
    spec: {
      template: {
        spec: {
          containers: [
            {
              name: "openldap",
              image: "osixia/openldap:1.5.0",
              ports: [
                { name: "ldap", containerPort: 389, },
              ],
              args: ["--skip-process-files"],
              env: [
                { name: "LDAP_ORGANISATION", value: config.organization },
                { name: "LDAP_DOMAIN", value: config.domain },
                { name: "LDAP_ADMIN_PASSWORD", value: config.adminUserPassword },
                { name: "LDAP_CONFIG_PASSWORD", value: config.configUserPassword },
                { name: "LDAP_READONLY_USER", value: "true" },
                { name: "LDAP_READONLY_USER_PASSWORD", value: config.readonlyUserPassword },
                { name: "LDAP_TLS", value: "false" },
              ],
              volumeMounts: [
                { name: "data", mountPath: "/var/lib/ldap", subPath: "database" },
                { name: "data", mountPath: "/etc/ldap/slapd.d", subPath: "config" },
              ],
            },
          ],
          volumes: [
            { name: "data", persistentVolumeClaim: { claimName: pvcName } },
          ],
          restartPolicy: "Never",
        },
      },
    },
  },
]

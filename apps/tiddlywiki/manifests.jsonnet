/*
*/
function(name, pvcName, config={}) (
  local nginxConfig = |||
    server {
      listen 0.0.0.0:3000;

      location = /auth-proxy {
        internal;

        proxy_pass http://127.0.0.1:8888;

        # URL and port for connecting to the LDAP server
        proxy_set_header X-Ldap-URL "ldap://%(ldapHost)s:%(ldapPort)s";

        # Base DN
        proxy_set_header X-Ldap-BaseDN "%(ldapBaseDN)s";

        # Bind DN
        proxy_set_header X-Ldap-BindDN "%(ldapBindDN)s";

        # Bind Password
        proxy_set_header X-Ldap-BindPass "%(ldapBindPassword)s";

        # Search
        proxy_set_header X-Ldap-Template "%(ldapSearchFilter)s";
      }

      location / {
        auth_request /auth-proxy;

        proxy_pass http://127.0.0.1:8080;
        proxy_set_header x-authenticated-user $remote_user;
      }
    }

    server {
      listen 0.0.0.0:4000;

      location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header x-authenticated-user "";
      }
    }
  ||| % {
    ldapHost: config.ldapHost,
    ldapPort: config.ldapPort,
    ldapBaseDN: config.ldapBaseDN,
    ldapBindDN: config.ldapBindDN,
    ldapBindPassword: config.ldapBindPassword,
    ldapSearchFilter: config.ldapSearchFilter,
  };

  [
    {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: name,
        labels: {
          "app.kubernetes.io/name": name,
        },
      },
      data: {
        "default.conf": nginxConfig,
      },
    },
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
                name: "tiddlywiki",
                image: "tintinho/tiddlywiki:5.1.23-armhf",
                command: [
                  "tiddlywiki",
                ],
                args: [
                  "/data",
                  "--listen",
                  "host=0.0.0.0",
                  "authenticated-user-header=x-authenticated-user",
                  "readers=(anon)",
                  "writers=(authenticated)",
                ],
                ports: [
                  { name: "http", containerPort: 8080 },
                ],
                volumeMounts: [
                  { name: "data", mountPath: "/data" },
                ],
              },
              {
                name: "nginx",
                image: "nginx:1.21.3",
                ports: [
                  { name: "http-private", containerPort: 3000 },
                  { name: "http-public", containerPort: 4000 },
                ],
                volumeMounts: [
                  { name: "nginx-config", mountPath: "/etc/nginx/conf.d" },
                ],
              },
              {
                name: "nginx-ldap-auth",
                image: "tintinho/nginx-ldap-auth:1-armhf",
                ports: [
                  { name: "http", containerPort: 8888 },
                ],
              },
            ],
            volumes: [
              {
                name: "data",
                persistentVolumeClaim: {
                  claimName: pvcName,
                },
              },
              {
                name: "nginx-config",
                configMap: {
                  name: name,
                },
              },
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
          {
            protocol: "TCP",
            port: 80,
            targetPort: 3000,
          },
        ],
        type: "ClusterIP",
      },
    },
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        name: name + "-readyonly",
      },
      spec: {
        selector: {
          "app.kubernetes.io/name": name,
        },
        ports: [
          {
            protocol: "TCP",
            port: 80,
            targetPort: 4000,
          },
        ],
        type: "ClusterIP",
      },
    },
  ]
)

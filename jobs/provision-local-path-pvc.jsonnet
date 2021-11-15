/*
Provision a persistent volume claim using the local-path provisioner built-in to k3s,
and optionally pinning it to a specific node
*/
function(pvcName, capacity="256Mi", nodeName=null) std.prune([
  {
    apiVersion: "v1",
    kind: "PersistentVolumeClaim",
    metadata: {
      name: pvcName,
    },
    spec: {
      accessModes: [
        "ReadWriteOnce",
      ],
      storageClassName: "local-path",
      resources: {
        requests: {
          storage: capacity,
        },
      },
    },
  },
  if nodeName != null then {
    apiVersion: "batch/v1",
    kind: "Job",
    metadata: {
      name: "pin-pvc-%s" % pvcName,
    },
    spec: {
      template: {
        spec: {
          containers: [
            {
              name: "main",
              image: "hello-world",
            },
          ],
          volumes: [
            {
              name: "data",
              persistentVolumeClaim: {
                claimName: pvcName,
              },
            },
          ],
          nodeSelector: { "kubernetes.io/hostname": nodeName },
          restartPolicy: "Never",
        },
      },
    },
  },
])

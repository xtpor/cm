/*
*/
function(jobName="", pvcName="", config={}) [
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
              name: "main",
              image: "tintinho/tiddlywiki:5.1.23-armhf",
              command: ["/bin/sh", "-c"],
              args: ["tiddlywiki /data --init server || true"],
              volumeMounts: [
                { name: "data", mountPath: "/data" },
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

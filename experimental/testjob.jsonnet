function (foo) {
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: "testjob",
  },
  spec: {
    template: {
      spec: {
        containers: [
          {
            name: "main",
            image: "hello-world",
            env: [
              { name: "TEST", value: foo },
            ],
          },
        ],
        restartPolicy: "Never",
      },
    },
  },
}
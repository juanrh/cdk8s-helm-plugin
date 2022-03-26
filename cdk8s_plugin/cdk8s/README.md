# cdk8s Helm plugin 

## Assumptions on cdk8s charts

- The cdk8s chart program is specified as a path to its root directory, so `cdk8s synth` synthesizes the chart. 
  - This directory should also contain a [Chart.yaml file](https://helm.sh/docs/topics/charts/#the-chartyaml-file) for Helm.
- When a file `values.yaml` is present in the same directory as the cdk8s chart program, then it will read it and use it as input props. 
- The cdk8s chart program generates its output in `dist/*.yaml`.

## Demo

```bash
$ make install
...
$ kubectl create namespace testns
namespace/testns created
$ helm -n testns list
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
$ cdk8s_chart_root="$(pwd)/../../hello-cdk8s"
# build example cdk8s chart
$ make -C ${cdk8s_chart_root}
...
# Install
$ helm -n testns cdk8s install hello-cdk8s-chart ${cdk8s_chart_root} ${cdk8s_chart_root}/values.yaml
...
$ helm -n testns list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
hello-cdk8s-chart       testns          1               2022-03-26 17:23:15.960078569 +0100 CET deployed        buildachart-0.1.0       0.1.0 
$ kubectl -n testns get deployments
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
hello-cdk8s-ghost-deployment-c83744f7   1/1     1            1           27s
hello-cdk8s-hello-deployment-c886f425   2/2     2            2           27s
# Upgrade
$ helm -n testns cdk8s upgrade hello-cdk8s-chart ${cdk8s_chart_root} ${cdk8s_chart_root}/values2.yaml --dry-run
...
    spec:
      containers:
        - image: paulbouwer/hello-kubernetes:1.7
          name: web
          ports:
            - containerPort: 8080

Running Helm upgrade cdk8s chart done
$ helm -n testns cdk8s upgrade hello-cdk8s-chart ${cdk8s_chart_root} ${cdk8s_chart_root}/values2.yaml
...
$ helm -n testns list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
hello-cdk8s-chart       testns          2               2022-03-26 17:24:49.81538591 +0100 CET  deployed        buildachart-0.1.0       0.1.0 
$ kubectl -n testns get deployments
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
hello-cdk8s-hello-deployment-c886f425   3/3     3            3           114s

# Rollback and uninstall as usual in Helm
$ helm -n testns rollback hello-cdk8s-chart
Rollback was a success! Happy Helming!
$ helm -n testns list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
hello-cdk8s-chart       testns          3               2022-03-26 17:26:14.916111137 +0100 CET deployed        buildachart-0.1.0       0.1.0  
$ kubectl -n testns get deployments
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
hello-cdk8s-ghost-deployment-c83744f7   1/1     1            1           39s
hello-cdk8s-hello-deployment-c886f425   2/2     2            2           3m37s

$ helm -n testns uninstall hello-cdk8s-chart
release "hello-cdk8s-chart" uninstalled
$ helm -n testns list
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
```

## Development

### Prerequisites

Optional: install [cdk8s CLI](https://cdk8s.io/docs/latest/getting-started/).  
We can use that command for scaffolding, e.g. `cdk8s init go-app`

### Common development tasks

Install with `make install`. After that an option "cdk8s" appears for `helm -h`.  

Then run the plugin `helm cdk8s <helm chart name> <cdk8s chart directory> [values yaml file]`


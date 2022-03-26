# cdk8s Helm plugin 

## Assumptions on cdk8s charts

- The cdk8s chart program is specified as a path to its root directory, so `cdk8s synth` synthesizes the chart. 
  - This directory should also contain a [Chart.yaml file](https://helm.sh/docs/topics/charts/#the-chartyaml-file) for Helm.
- When a file `values.yml` is present in the same directory as the cdk8s chart program, then it will read it and use it as input props. 
- The cdk8s chart program generates its output in `dist/*.yaml`.

## Demo

```bash
make install
helm -n testns list
kubectl create namespace testns
cdk8s_chart_root="$(pwd)/../../hello-cdk8s"
# Install
helm -n testns cdk8s install hello-cdk8s-chart ${cdk8s_chart_root} ${cdk8s_chart_root}/values.yml
helm -n testns list
kubectl -n testns get deployments
# Upgrade
helm -n testns cdk8s upgrade hello-cdk8s-chart ${cdk8s_chart_root} ${cdk8s_chart_root}/values2.yml --dry-run
helm -n testns cdk8s upgrade hello-cdk8s-chart ${cdk8s_chart_root} ${cdk8s_chart_root}/values2.yml
helm -n testns list

# Rollback and uninstall as usual in Helm
helm -n testns rollback hello-cdk8s-chart
helm -n testns list
helm -n testns uninstall hello-cdk8s-chart
helm -n testns list
```

## Development

### Prerequisites

Optional: install [cdk8s CLI](https://cdk8s.io/docs/latest/getting-started/).  
We can use that command for scaffolding, e.g. `cdk8s init go-app`

### Common development tasks

Install with `make install`. After that an option "cdk8s" appears for `helm -h`.  

Then run the plugin `helm cdk8s <helm chart name> <cdk8s chart directory> [values yaml file]`


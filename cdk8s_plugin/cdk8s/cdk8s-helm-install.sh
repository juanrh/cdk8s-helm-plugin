#!/usr/bin/env bash

# Example usage
# export HELM_NAMESPACE=testns # this is set by Helm plugin system
# ./cdk8s-helm-install.sh hello-cdk8s-chart ../../hello-cdk8s

set -eu

# TODO: Pass other flags to helm
if (($# < 3 || $# > 4)); then
  echo "Usage: $0 <helm chart name> <cdk8s chart directory> [values yaml file]"
  exit 1
fi

# currently only 'install' and 'upgrade' supported. TODO: validate 
HELM_VERB=${1}
CHART_NAME=${2}
CHART_ROOT=${3}
CHART_VALUES=${4:-''}

VALUES_FILENAME='values.yml'
HELM_CHART_ROOT='chart'

echo "Installing cdk chart using CHART_NAME='${CHART_NAME}' CHART_ROOT='${CHART_ROOT}', CHART_VALUES='${CHART_VALUES}'"
temp_dir=$(mktemp -d)
pushd ${temp_dir}


echo "Fetching cdk8s chart"
cp -r ${CHART_ROOT}/* .
if [ ! -z "${CHART_VALUES}" ]
then
    cp ${CHART_VALUES} ${VALUES_FILENAME}
fi
echo "Fetching cdk8s chart done"

echo "Synthesizing cdk8s chart"
cdk8s synth
mkdir ${HELM_CHART_ROOT}
cp Chart.yaml ${HELM_CHART_ROOT}
cp dist/*.yaml ${HELM_CHART_ROOT}
tree ${HELM_CHART_ROOT}
echo "Synthesizing cdk8s chart done"

echo "Installing cdk8s chart"
helm -n $HELM_NAMESPACE ${HELM_VERB} ${CHART_NAME} ${HELM_CHART_ROOT}
echo "Installing cdk8s chart done"


popd
rm -rf ${temp_dir}

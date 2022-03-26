#!/usr/bin/env bash

# Example usage
# export HELM_NAMESPACE=testns # this is set by Helm plugin system
# ./cdk8s-helm.sh hello-cdk8s-chart install ../../hello-cdk8s

set -eu

# TODO: Pass other flags to helm
if (($# < 3 )); then
  echo "Usage: $0 <helm chart name> <cdk8s chart directory> [values yaml file] [other helm arguments]"
  exit 1
fi

# currently only 'install' and 'upgrade' supported. TODO: validate 
HELM_VERB=${1}
shift
CHART_NAME=${1}
shift
CHART_ROOT=${1}
shift
CHART_VALUES=${1:-''}
shift

VALUES_FILENAME='values.yaml'
HELM_CHART_ROOT='chart'

echo "Running Helm ${HELM_VERB} cdk chart using CHART_NAME='${CHART_NAME}' CHART_ROOT='${CHART_ROOT}', CHART_VALUES='${CHART_VALUES}'"
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
mkdir ${HELM_CHART_ROOT}/templates
cp dist/*.yaml ${HELM_CHART_ROOT}/templates
tree ${HELM_CHART_ROOT}
echo "Synthesizing cdk8s chart done"

echo "Running Helm ${HELM_VERB} cdk8s chart"
${HELM_BIN} -n $HELM_NAMESPACE ${HELM_VERB} ${CHART_NAME} ${HELM_CHART_ROOT} "$@"
echo "Running Helm ${HELM_VERB} cdk8s chart done"


popd
rm -rf ${temp_dir}

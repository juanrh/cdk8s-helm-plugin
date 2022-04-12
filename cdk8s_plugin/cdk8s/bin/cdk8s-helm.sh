#!/usr/bin/env bash

set -eu

# TODO: Pass other flags to helm
if (($# < 3 )); then
  echo "Usage:"
  echo "$0 [install|upgrade] <helm chart name> <cdk8s chart URI> [values yaml file] [other helm arguments]"
  echo "$0 publish <cdk8s chart root path> <cdk8s chart URI>"
  exit 1
fi

# TODO: validate 
VERB=${1}
shift
case $VERB in
  publish)
    CDK_CHART_ROOT=${1}
    shift
    CHART_URI=${1}
    shift
    echo "Running cdk ${VERB} chart using CDK_CHART_ROOT='${CDK_CHART_ROOT}' CHART_URI='${CHART_URI}'"
    ;;
    

  *)
    CHART_NAME=${1}
    shift
    CHART_URI=${1}
    shift
    CHART_VALUES=${1:-''}
    shift || true
    echo "Running cdk ${VERB} chart using CHART_NAME='${CHART_NAME}' CHART_URI='${CHART_URI}', CHART_VALUES='${CHART_VALUES}'"
    ;;
esac
OTHER_HELM_ARGS=$@

VALUES_FILENAME='values.yaml'
HELM_CHART_ROOT='chart'

function run_helm {
  echo "Running Helm ${VERB} cdk8s chart"
  ${HELM_BIN} -n $HELM_NAMESPACE ${VERB} ${CHART_NAME} ${HELM_CHART_ROOT} $OTHER_HELM_ARGS
  echo "Running Helm ${VERB} cdk8s chart done"
}

function run_chart_local {
  temp_dir=$(mktemp -d)
  pushd ${temp_dir}


  echo "Fetching cdk8s chart"
  cp -r ${CHART_URI}/* .
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

  run_helm

  popd
  rm -rf ${temp_dir}
}

function chart_uri_type {
  # Examples:
  # chart_uri_type oci://juanrh/cdk-chart-hello-cdk8s:latest
  # chart_uri_type chart_uri_type $(pwd)/../../hello-cdk8s
  URI="${1}"

  echo ${URI} | grep -q '^oci://'
  if [ "$?" -eq "0" ]
  then
    echo "oci";
  else
    # NOTE: defaulting to local
    echo "local"
  fi
}


function publish_chart {
  echo "Publishing chart to ${CHART_URI}"

  if [ $(chart_uri_type ${CHART_URI}) != "oci" ]
  then
    echo "Currently only the scheme 'oci://' for OCI registry is supported, abort"
    exit 1
  fi 

  temp_dir=$(mktemp -d)
  pushd ${temp_dir}

  echo "Only Golang CDK charts are currently supported, assuming Golang chart"
  cp ${HELM_PLUGIN_DIR}/Dockerfile .
  mkdir src
  cp -r ${CDK_CHART_ROOT} src
  image_tag=${CHART_URI#oci://}
  echo "Building image ${image_tag}"
  docker build --build-arg chart_basename=$(basename ${CDK_CHART_ROOT}) -t ${image_tag} .
  echo "Pushing image ${image_tag}"
  docker push ${image_tag}


  popd
  rm -rf ${temp_dir}
}

function run_chart_oci {
  temp_dir=$(mktemp -d)
  pushd ${temp_dir}

  mount_values=""
  if [ ! -z "${CHART_VALUES}" ]
  then
      mount_values="-v $(realpath ${CHART_VALUES}):/go/src/values.yaml"
  fi
  image_tag=${CHART_URI#oci://}
  echo "Fetching cdk8s chart"
  docker pull ${image_tag}
  echo "Fetching cdk8s chart done"

  echo "Synthesizing cdk8s chart"
  cdk_run="cdk-synth-${CHART_NAME}-$(date +%s)"
  docker run -it --name ${cdk_run} ${mount_values} ${image_tag} /bin/bash -c '((ls /go/src/values.yaml && rm -f values.yaml && ln -s /go/src/values.yaml values.yaml) || true) && mkdir -p ../chart/templates && cp Chart.yaml ../chart && cdk8s synth && cp dist/*.yaml ../chart/templates'
  mkdir ${HELM_CHART_ROOT}
  docker cp ${cdk_run}:/go/src/chart/Chart.yaml ${HELM_CHART_ROOT}
  docker cp ${cdk_run}:/go/src/chart/templates ${HELM_CHART_ROOT}
  docker container rm ${cdk_run}
  tree ${HELM_CHART_ROOT}
  echo "Synthesizing cdk8s chart done"

  run_helm


  popd
  rm -rf ${temp_dir}
}

case $VERB in
  publish)
    publish_chart
    ;;


  *)
    case $(chart_uri_type ${CHART_URI}) in
      local)
        run_chart_local
        ;;
      oci)
        run_chart_oci
        ;;
    esac
    ;;
esac

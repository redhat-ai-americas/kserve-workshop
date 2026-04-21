#!/bin/bash

# shellcheck disable=SC1091

################# standard init #################

export SLEEP_SECONDS=8

check_shell(){
  [ -n "$BASH_VERSION" ] && return
  echo -e "${ORANGE}WARNING: These scripts are ONLY tested in a bash shell${NC}"
  sleep "${SLEEP_SECONDS:-8}"
}

check_git_root(){
  if [ -d .git ] && [ -d scripts ]; then
    GIT_ROOT=$(pwd)
    export GIT_ROOT
    echo "GIT_ROOT:   ${GIT_ROOT}"
  else
    echo "Please run this script from the root of the git repo"
    exit
  fi
}

get_script_path(){
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  echo "SCRIPT_DIR: ${SCRIPT_DIR}"
}

check_shell
check_git_root
get_script_path

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/functions.sh"

validate_cli(){
  echo ""
  echo "Validating command requirements..."
  bin_check oc
  bin_check jq
  echo ""
}

help(){
  loginfo "KServe workshop prerequisite setup (Web Terminal + console banner + tooling)"
  loginfo "Usage: $(basename "$0") -s <step-number>"
  loginfo "Options:"
  loginfo " -h, --help   usage"
  loginfo " -s, --step   step number (required)"
  loginfo "        0       - Install prerequisites (Web Terminal, console banner, tooling template)"
  return 0
}

while getopts ":h:s:" flag; do
  case $flag in
    h) help ;;
    s) s=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&1; exit 1 ;;
  esac
done

step_0(){
  logbanner "Install prerequisites"

  retry oc apply -f "${GIT_ROOT}"/configs/00/web-terminal-subscription.yaml

  while [ -z "$INSTALL_PLAN" ]
  do
    INSTALL_PLAN=$(oc get installplan -n openshift-operators -o json | jq '.items[] | select(.spec.clusterServiceVersionNames[] | contains  ("web-terminal")) | .metadata.name' | tr -d \")
  done
  log "$INSTALL_PLAN"

  retry oc patch installplan "$INSTALL_PLAN" \
    --namespace openshift-operators \
    --type merge \
    --patch '{"spec":{"approved":true}}'

  retry oc apply -f "${GIT_ROOT}"/configs/00/

  validate_cli || echo "!!!NOTICE: you are missing cli tools needed!!!"
}

setup(){

  if [ -z "$s" ]; then
      logerror "Step number is required"
      help
      exit 1
  fi

  if [ "$s" = "0" ] ; then
      loginfo "Running step 0"
      step_0
      exit 0
  fi

  logerror "Only step 0 is defined for this workshop; see docs/00-setup.md for manual lab steps"
  exit 1
}

is_sourced || setup

#!/usr/bin/env bash

# Copyright 2019 Cornelius Weig
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[[ -n $DEBUG ]] && set -x

set -eEuo pipefail

declare -a TMPFILES=()
cleanup() {
  if [[ "${#TMPFILES[@]}" -gt 0 ]]; then
    rm -- "${TMPFILES[@]}"
  fi
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
konfig helps to merge, split or import kubeconfig files

USAGE:
  konfig merge [--preserve-structure,-p] <CONFIG>..
     Merge multiple kubeconfigs into one.
     -p  prevents flattening which will make the result less portable.

  konfig import [--preserve-structure,-p] [--save,-s] [--stdin,-i] <CONFIG>..
     Import the given configs into your current kubeconfig (respects KUBECONFIG env var).
     -s  writes the result to your ~/.kube/config
     -i  import kubeconfig string from stdin

  konfig split  <CONTEXT>.. [--kubeconfig,-k <CONFIG>]
  konfig export <CONTEXT>.. [--kubeconfig,-k <CONFIG>]
     Export/split off a minimal kubeconfig with the given contexts
      -k  may be repeated or contain a comma-delimited list of input configs.
          When omitted, export from the default kubeconfig.

EXAMPLES:
  Merge new-cfg with your current kubeconfig
    $ konfig import new-cfg
  and save the result to ~/.kube/config
    $ konfig import --save new-cfg
  CAVEAT: due to how shells work, the following will lose your current ~/.kube/config
    WRONG $ konfig import new-cfg > ~/.kube/config

  Export ctx1 and ctx2 into combined.yaml
    $ konfig export -k ~/.kube/config -k k3s.yaml ctx1 ctx2 > combined.yaml

  Merge two configs
    $ konfig merge ~/.kube/config k3s.yaml > merged-and-flattened
    or
    $ konfig merge -p ~/.kube/config k3s.yaml > merged-not-flattened

EOF
}

error() {
  echo "error: $1" >&2
  exit 1
}

merge() {
    if [[ "$1" =~ ^-.+ && "$1" != '-p' && "$1" != '--preserve-structure' ]]; then
      error "unrecognized flag \"$1\""
    else
      IFS=$':\n\t'
      if [[ "$1" == '-p' || "$1" == '--preserve-structure' ]]; then
        KUBECONFIG="${*:2}" $KUBECTL config view --raw --merge
      else
        KUBECONFIG="$*" $KUBECTL config view --flatten --merge
      fi
      IFS=$' \t\n'
    fi
}

import_ctx() {
    declare -a tmpcfgs=()
    local tmpcfg
    local tmpinputcfg=""
    local out=""
    local arg=""

    tmpcfg=$(mktemp konfig_XXXXXX)
    TMPFILES+=( "$tmpcfg" )
    tmpcfgs+=( "$tmpcfg")

    for OPT in "$@"; do
      case $OPT in
        -p | --preserve-structure)
          arg="$1"
          shift
          ;;
        -s | --save)
          out="${XDG_CACHE_HOME:-$HOME/.kube}/config"
          shift
          ;;
        -i | --stdin)
          if [[ -p /dev/stdin ]]; then
            tmpinputcfg=$(mktemp konfig_input_XXXXXX)
            TMPFILES+=( "$tmpinputcfg" )
            tmpcfgs+=( "$tmpinputcfg" )
            cat - > "$tmpinputcfg"
            shift
          fi
          ;;
        -*)
          error "unrecognized flag \"$1\""
          ;;
      esac
    done
    $KUBECTL config view --raw > "$tmpcfg"

    if [[ -z "$out" ]]; then
      merge "$arg" "${tmpcfgs[@]}" "$@"
    else
      trap 'mv "$tmpcfg" "$out"' ERR
      merge "$arg" "${tmpcfgs[@]}" "$@" > "$out"
    fi
}

export_contexts() {
    declare -a ctxs=()
    declare -a cfgs=()
    declare -a tmpcfgs=()
    local tmpcfg

    while [[ "$#" -gt 0 ]]; do
      if [[ "$1" == '--kubeconfig' || "$1" == '-k' ]]; then
        cfgs+=( "${2//,/:}" )
        shift 2
      elif [[ "$1" =~ ^-.+ ]]; then
        error "unrecognized flag \"$1\""
      else
        ctxs+=( "$1" )
        shift
      fi
    done

    if [[ "${#ctxs[@]}" -eq 0 ]]; then
      error "contexts to export are missing"
    fi

    for x in "${ctxs[@]}"; do
      tmpcfg=$(mktemp konfig_XXXXXX)
      TMPFILES+=( "$tmpcfg" )
      tmpcfgs+=( "$tmpcfg" )
      if [[ "${#cfgs[@]}" -eq 0 ]]; then
        $KUBECTL config view --flatten --minify --context="$x" > "$tmpcfg"
      else
        IFS=$':\n\t'
        KUBECONFIG="${cfgs[*]}" $KUBECTL config view --flatten --minify --context="$x" > "$tmpcfg"
        IFS=$' \n\t'
      fi
    done

    merge "${tmpcfgs[@]}"
}

main() {
  if hash kubectl 2>/dev/null; then
    KUBECTL=kubectl
  elif hash kubectl.exe 2>/dev/null; then
    KUBECTL=kubectl.exe
  else
    echo >&2 "kubectl is not installed"
    exit 1
  fi

  if [[ "$#" -eq 0 ]]; then
    usage
    return
  fi

  case "$1" in
  '-h' | '--help' | 'help')
    usage
    ;;
  'export'|'split')
    export_contexts "${@:2}"
    ;;
  'import')
    import_ctx "${@:2}"
    ;;
  'merge')
    merge "${@:2}"
    ;;
   -*)
    usage
    error "unrecognized flag \"${1}\""
    ;;
   *)
    usage
    error "unknown command \"$1\""
  esac

}

main "$@"

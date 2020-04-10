#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

export LOG_LEVEL="${LOG_LEVEL:-600}"
# shellcheck disable=SC1090
. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.bashtools/bashtools"

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PATH="${SCRIPT_FOLDER}/.jsonnet:${SCRIPT_FOLDER}/.dockertools:${PATH}"

MASTER_JSONNET="${1}"
MASTER_ID="${2:-}"

TOOLS_IMAGE="eclipsecbi/adoptopenjdk-coreutils:openjdk8-openj9-alpine-slim"
BUILD_DIR="${SCRIPT_FOLDER}/target/"
MASTER_JSON="${BUILD_DIR}/masters.json"

# gen the computed masters.json (mainly for .masters[])
mkdir -p "${BUILD_DIR}/"
jsonnet "${MASTER_JSONNET}" > "${MASTER_JSON}"

DEBUG "Removing potential dust (*.lock) of install-plugins.sh from previous runs"
find "${BUILD_DIR}" -type d -name "*.lock" -delete

# latest Jenkins id
latest_id=$(jq -r '.releases.latest' "${MASTER_JSON}")

download_war_file() {
  local config="${1}"
  local build_dir
  build_dir="$(dirname "${config}")"
  INFO "Downloading and verifying Jenkins war file"
  
  local version key_fingerprint war_base_url war_file
  version="$(jq -r '.version' "${config}")"
  key_fingerprint="$(jq -r '.key_fingerprint' "${config}")"
  war_base_url="$(jq -r '.warBaseUrl' "${config}")"
  war_file="war/$(basename "$(jq -r '.war' "${config}")")"
  jq -r '.pubkey' "${config}" > "${build_dir}/${war_file}.pub.asc"

  printf "War base URL: %s\n" "${war_base_url}" | DEBUG

  docker run -u "$(id -u):$(id -g)" --rm \
    -v "${build_dir}:/tmp/workdir" \
    -w "/tmp/workdir" \
    -e HOME="/tmp/workdir" \
    --entrypoint "" \
    "${TOOLS_IMAGE}" \
    /bin/bash -c \
      "curl -fsSL '${war_base_url}/jenkins-war-${version}.war.asc' -o '${war_file}.asc' -z '${war_file}.asc' \
      && curl -fsSL '${war_base_url}/jenkins-war-${version}.war' -o '${war_file}' -z '${war_file}' \
      && gpg -q --batch --import '${war_file}.pub.asc' \
      && echo -e '5\ny\n' |  gpg -q --batch --command-fd 0 --expert --edit-key ${key_fingerprint} trust 2> /dev/null \
      && gpg -q --batch --verify '${war_file}.asc' '${war_file}' 2>&1 /dev/null" |& TRACE

  # Check if embedded remoting version as declared by war file == the one declared in masters.jsonnet
  local remoting_embedded_version
  remoting_embedded_version="$(unzip -p "${build_dir}/${war_file}" META-INF/MANIFEST.MF | grep "Remoting-Embedded-Version" | cut -d: -f2 | tr -d '[:space:]')"
  if [[ "${remoting_embedded_version}" != "$(jq -r '.remoting.version' "${config}")" ]]; then
    ERROR "ERROR: Remoting version specified for Jenkins ${version} (read $(jq -r '.remoting.version' "${config}")) does not match the one from WAR file (expected ${remoting_embedded_version})"
    exit 1
  else
    printf "Embedded remoting version %s matches with the remoting version specified in %s\n" "${remoting_embedded_version}" "${MASTER_JSONNET}" | DEBUG
  fi
}

download_plugins() {
  local config="${1}"
  local build_dir
  build_dir="$(dirname "${config}")"
  INFO "Downloading Jenkins plugins to be installed"

  local updateCenter war_file
  updateCenter="$(jq -r '.updateCenter' "${config}")"
  war_file="war/$(basename "$(jq -r '.war' "${config}")")"
  printf "Downloading plugins from update center '%s'" "${updateCenter}\n" | DEBUG

  docker run -u "$(id -u):$(id -g)" --rm \
    -v "${build_dir}/scripts:/usr/local/bin" \
    -v "${build_dir}:/tmp/workdir" \
    -w "/tmp/workdir" \
    -e HOME="/tmp/workdir" \
    --entrypoint "" \
    "${TOOLS_IMAGE}" \
    /bin/bash -c \
      "export REF='/tmp/workdir/ref' \
      && export JENKINS_WAR='/tmp/workdir/${war_file}' \
      && export JENKINS_UC='${updateCenter}' \
      && export CURL_RETRY='8' \
      && export CURL_RETRY_MAX_TIME='120' \
      && ./tools/install-plugins.sh < plugins.txt" | TRACE
}

build_docker_image() {
  local config="${1}"
  local build_dir
  build_dir="$(dirname "${config}")"

  local image tag
  # $(jq -r '.docker.registry' "${config}")/
  image="$(jq -r '.docker.repository' "${config}")/$(jq -r '.docker.image' "${config}")"
  tag="$(jq -r '.docker.tag' "${config}")"
  local latest="false"
  if [[ "${id}" = "${latest_id}" ]]; then
    latest="true"
  fi
  
  INFO "Building and pushing docker image ${image}:${tag} (latest=${latest})"
  dockerw build "${image}" "${tag}" "${build_dir}/Dockerfile" "${build_dir}" "true" "${latest}" |& TRACE
}

build_master() {
  local id="${1}"
  local instance_dir="${BUILD_DIR}/${id}"
  local instance_config="${instance_dir}/config.json"

  INFO "Building jiro-master '${id}' in '${instance_dir}'"
  mkdir -p "${instance_dir}/war" "${instance_dir}/ref"

  INFO "Generate instance files from templates"
  jq -r '.masters[] | select(.id=="'"${id}"'")' "${MASTER_JSON}" > "${instance_config}"
  jq -r '.dockerfile' "${instance_config}" > "${instance_dir}/Dockerfile"
  jq -r '.plugins[]' "${instance_config}" > "${instance_dir}/plugins.txt"

  INFO "Downloading support scripts"
  download ifmodified "$(jq -r '.scripts.install_plugins' "${instance_config}")" "${instance_dir}/tools/install-plugins.sh"
  download ifmodified "$(jq -r '.scripts.jenkins_support' "${instance_config}")" "${instance_dir}/scripts/jenkins-support"
  download ifmodified "$(jq -r '.scripts.jenkins' "${instance_config}")" "${instance_dir}/scripts/jenkins.sh"
  chmod u+x "${instance_dir}/scripts/"*.sh "${instance_dir}/tools/"*.sh

  download_war_file "${instance_config}"

  download_plugins "${instance_config}"

  build_docker_image "${instance_config}"
}

if [[ -n ${MASTER_ID} ]]; then
  build_master "${MASTER_ID}"
else 
  for id in $(jq -r '.masters[].id' "${MASTER_JSON}"); do
    build_master "${id}"
  done
fi

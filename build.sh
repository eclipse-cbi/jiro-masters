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
PATH="${SCRIPT_FOLDER}/.dockertools:${PATH}"

JIRO_JSONNET="${1}"
CONTROLLER_ID="${2:-}"
PUSH_IMAGES="${PUSH_IMAGES:-"true"}"

TOOLS_IMAGE="eclipsecbi/eclipse-temurin-coreutils:17-alpine"
BUILD_DIR="${SCRIPT_FOLDER}/target/"
CONTROLLERS_JSON="${BUILD_DIR}/controllers.json"

IMAGE_WD="/workdir"

download_war_file() {
  local config="${1}"
  local build_dir
  build_dir="$(dirname "${config}")"
  INFO "Downloading and verifying Jenkins war file"

  mkdir -p "${config_dir}/war"

  local version key_fingerprint war_base_url war_file
  version="$(jq -r '.version' "${config}")"
  key_fingerprint="$(jq -r '.key_fingerprint' "${config}")"
  war_base_url="$(jq -r '.warBaseUrl' "${config}")"
  war_file="war/$(basename "$(jq -r '.war' "${config}")")"
  pubkey_file="$(jq -r '.pubkey' "${config}")"
  cat "${pubkey_file}" > "${build_dir}/${war_file}.pub.asc"

  printf "War base URL: %s\n" "${war_base_url}" | DEBUG

  docker run -u "$(id -u):$(id -g)" --rm \
    -v "${build_dir}:${IMAGE_WD}" \
    -w "${IMAGE_WD}" \
    -e HOME="${IMAGE_WD}" \
    --entrypoint "" \
    "${TOOLS_IMAGE}" \
    /bin/bash -c \
      "curl -fsSL '${war_base_url}/jenkins-war-${version}.war.asc' -o '${war_file}.asc' -z '${war_file}.asc' \
      && curl -fsSL '${war_base_url}/jenkins-war-${version}.war' -o '${war_file}' -z '${war_file}' \
      && gpg -q --batch --import '${war_file}.pub.asc' \
      && echo -e '5\ny\n' |  gpg -q --batch --command-fd 0 --expert --edit-key ${key_fingerprint} trust 2> /dev/null \
      && gpg -q --batch --verify '${war_file}.asc' '${war_file}' 2>&1 /dev/null" |& TRACE

  # Check if embedded remoting version as declared by war file >= the one declared in controllers.jsonnet
  local remoting_embedded_version remoting_version
  remoting_embedded_version="$(unzip -p "${build_dir}/${war_file}" META-INF/MANIFEST.MF | grep "Remoting-Embedded-Version" | cut -d: -f2 | tr -d '[:space:]')"
  remoting_version="$(jq -r '.remoting.version' "${config}")"
  if [[ "$(versions compare "${remoting_version}" "${remoting_embedded_version}")" -lt 0 ]]; then
    printf "Remoting version (%s) specified for Jenkins %s does not match the one from the WAR file (expected >= %s)\n" "${remoting_version}" "${version}" "${remoting_embedded_version}" | ERROR
    exit 1
  else
    printf "Embedded remoting version %s matches with the remoting version specified in %s\n" "${remoting_embedded_version}" "${JIRO_JSONNET}" | DEBUG
  fi
}

download_plugins() {
  local config="${1}"
  local build_dir
  build_dir="$(dirname "${config}")"
  INFO "Downloading Jenkins plugins to be installed"

  mkdir -p "${config_dir}/ref"
  mkdir -p "$(readlink -f "${build_dir}/../cache")"

  jq -r '.plugins[]' "${config}" > "${build_dir}/plugins.txt"

  local updateCenter war_file
  updateCenter="$(jq -r '.updateCenter' "${config}")"
  war_file="war/$(basename "$(jq -r '.war' "${config}")")"
  printf "Downloading plugins from update center '%s'" "${updateCenter}\n" | DEBUG

  docker run -u "$(id -u):$(id -g)" --rm \
    -v "$(readlink -f "${build_dir}/../cache"):/cache" \
    -v "${build_dir}/scripts:/usr/local/bin" \
    -v "${build_dir}:${IMAGE_WD}" \
    -w "${IMAGE_WD}" \
    -e HOME="${IMAGE_WD}" \
    --entrypoint "" \
    "${TOOLS_IMAGE}" \
    /bin/bash -c \
      "export CACHE_DIR=/cache && \
      java -jar ./tools/jenkins-plugin-manager.jar \
        --plugin-file plugins.txt \
        --list \
        --view-security-warnings \
        --plugin-download-directory '${IMAGE_WD}/ref/plugins' \
        --jenkins-update-center '${updateCenter}' \
        --war '${IMAGE_WD}/${war_file}' > ${IMAGE_WD}/plugins.log" | TRACE
}

build_docker_image() {
  local config="${1}"
  local build_dir
  build_dir="$(dirname "${config}")"

  jq -r '.dockerfile' "${config}" > "${build_dir}/Dockerfile"

  local id image tag images
  id="$(jq -r '.id' "${config}")"
  image="$(jq -r '.docker.registry' "${config}")/$(jq -r '.docker.repository' "${config}")/$(jq -r '.docker.image' "${config}")"
  tag="$(jq -r '.docker.tag' "${config}")"
  images="${image}:${tag}"
  if [[ "${id}" = "${LATEST_ID}" ]]; then
    images="${images},${image}:latest"
  fi

  INFO "Building docker image ${images} (push=${PUSH_IMAGES})"
  dockerw build2 "${images}" "${build_dir}/Dockerfile" "${build_dir}" "${PUSH_IMAGES}" |& TRACE
}

build_controller() {
  local id="${1}"
  local config_dir="${BUILD_DIR}/${id}"
  local config="${config_dir}/config.json"

  INFO "Building jiro-controller '${id}'"

  mkdir -p "${config_dir}"
  jq -r '.controllers["'"${id}"'"]' "${CONTROLLERS_JSON}" > "${config}"

  download_war_file "${config}"

  INFO "Downloading support scripts"
  download ifmodified "$(jq -r '.plugin_manager.jar' "${config}")" "${config_dir}/tools/jenkins-plugin-manager.jar"
  download ifmodified "$(jq -r '.scripts.jenkins_support' "${config}")" "${config_dir}/scripts/jenkins-support"
  download ifmodified "$(jq -r '.scripts.jenkins' "${config}")" "${config_dir}/scripts/jenkins.sh"

  download_plugins "${config}"
  build_docker_image "${config}"
  INFO "Building jiro-controller '${id}' done."
  echo
}

# gen the computed controllers.json (mainly for .controllers[])
mkdir -p "${BUILD_DIR}/"
jsonnet "${JIRO_JSONNET}" > "${CONTROLLERS_JSON}"

DEBUG "Removing potential dust (*.lock) of install-plugins.sh from previous runs"
find "${BUILD_DIR}" -type d -name "*.lock" -delete

# latest Jenkins id
LATEST_ID=$(jq -r '.latest' "${CONTROLLERS_JSON}")
printf "Jenkins latest id=%s\n" "${LATEST_ID}" | DEBUG

# main
if [[ -n ${CONTROLLER_ID} ]]; then
  build_controller "${CONTROLLER_ID}"
else
  for id in $(jq -r '.controllers | keys[]' "${CONTROLLERS_JSON}"); do
    build_controller "${id}"
  done
fi

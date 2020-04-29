#!/usr/bin/env bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

readonly SCRIPT_ROOT="$(cd $(dirname ${BASH_SOURCE[0]} ) && pwd)"

source "${SCRIPT_ROOT}/vars.sh"

# TODO(phosek): remove this after we finish migration to CIPD
rm -rf "${BUILDTOOLS_DIR}/linux64" "${BUILDTOOLS_DIR}/mac" "${BUILDTOOLS_DIR}/win"
if [[ ! -d "${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}/.cipd" ]]; then
  rm -rf "${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}"
fi

${SCRIPT_ROOT}/cipd ensure -ensure-file "${SCRIPT_ROOT}/fuchsia.ensure" -root "${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}" -log-level warning

###############################################################################
# From zircon/scripts/download-toolchain
###############################################################################
readonly NEBULA_GS_BUCKET="http://gle43/components/nebula"
readonly OS="$(uname)"
readonly HOSTOS=$(uname | tr '[:upper:]' '[:lower:]')
readonly HOSTARCH="$(uname -m)"
readonly PREBUILTS_DIR="${BUILDTOOLS_DIR}"
readonly INSTALL_DIR="${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}"

function downloadToolchain() {
  local toolchain="${1}"

  case "${OS}-${HOSTARCH}" in
    "Darwin-x86_64") local host_platform="mac-amd64" ;;
    "Linux-x86_64") local host_platform="linux-amd64" ;;
    "Linux-aarch64") local host_platform="linux-aarch64" ;;
    "*") echo "Unknown operating system." 1>&2 && exit 1 ;;
  esac

  # These are files and paths we expect to already exist.
  local common_path="toolchain/${toolchain}/${host_platform}"
  local version_file="${PREBUILTS_DIR}/versions/${common_path}/${toolchain}.sha1"
  if [[ ! -f "${version_file}" ]]; then
    echo "File ${version_file} does not exist."
    echo "Your operating system is probably not supported, aborting ${toolchain} download."
    return
  fi
  local required_version="$(cat "${version_file}" )"
  local prebuilt_url="${NEBULA_GS_BUCKET}/${toolchain}/${host_platform}/${required_version}"

  # These are files and paths we control in this script.
  local stamp_path="${INSTALL_DIR}/${toolchain}.stamp"
  local tool_path="${INSTALL_DIR}/${toolchain}.zip"

  # The stamp file contains the SHA of the last version we downloaded.  If it doesn't
  # match the SHA found in the version file, download and unpack the new one.
  cd ${INSTALL_DIR}
  if [[ ! -f "${stamp_path}" || "${required_version}" != "$(cat ${stamp_path})" ]]; then
    rm -f -- "${tool_path}"
    echo "Downloading ${prebuilt_url}"
    curl --progress-bar -continue-at=- --location --output "${tool_path}" "${prebuilt_url}"
    rm -rf -- "${toolchain}"
    echo "Unpacking ${tool_path}"
    unzip -q -d "${INSTALL_DIR}/${toolchain}" "${tool_path}"
    echo "${required_version}" > "${stamp_path}"
  fi
}

downloadToolchain clang

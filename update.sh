#!/usr/bin/env bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

readonly SCRIPT_ROOT="$(cd $(dirname ${BASH_SOURCE[0]} ) && pwd)"

source "${SCRIPT_ROOT}/vars.sh"

# TODO(phosek): remove this after we finish migration to CIPD
rm -rf "${BUILDTOOLS_DIR}/linux64" "${BUILDTOOLS_DIR}/mac" "${BUILDTOOLS_DIR}/win"
#if [[ ! -d "${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}/.cipd" ]]; then
  rm -rf "${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}"
#fi

#${SCRIPT_ROOT}/cipd ensure -ensure-file "${SCRIPT_ROOT}/fuchsia.ensure" -root "${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}" -log-level warning

pushd ${BUILDTOOLS_DIR} > /dev/null

date
base_url="http://www/components"
tarball="buildtools-linux-x64.tar.gz"
if [[ ! -f "${tarball}" ]]; then
  echo "Downloading ${tarball} ..."

  wget "${base_url}/${tarball}"
  wget "${base_url}/${tarball}.sha1sum"
  sha1sum -c ${tarball}.sha1sum
else
  echo "${tarball} already downloaded."
fi
date

echo "Extracting ${tarball} ..."
tar xf ${tarball}
echo -e "\nDone."
date

popd

###############################################################################
# From zircon/scripts/download-toolchain
###############################################################################
readonly OS="$(uname)"
readonly HOSTOS=$(uname | tr '[:upper:]' '[:lower:]')
readonly HOSTARCH="$(uname -m)"
readonly INSTALL_DIR="${BUILDTOOLS_DIR}/${BUILDTOOLS_PLATFORM}"
# Use relative path so it wont' break when FUCHSIA_ROOT changes.
readonly PREBUILT_DIR="../../zircon/prebuilt/downloads"

rm -rf ${INSTALL_DIR}/clang
rm -rf ${INSTALL_DIR}/clang.stamp
ln -s ${PREBUILT_DIR}/clang ${INSTALL_DIR}/clang
ln -s ${PREBUILT_DIR}/clang.stamp ${INSTALL_DIR}/clang.stamp

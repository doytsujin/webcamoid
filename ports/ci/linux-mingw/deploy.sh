#!/bin/bash

# Webcamoid, webcam capture application.
# Copyright (C) 2017  Gonzalo Exequiel Pedone
#
# Webcamoid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Webcamoid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Webcamoid. If not, see <http://www.gnu.org/licenses/>.
#
# Web-Site: http://webcamoid.github.io/

if [ ! -z "${GITHUB_SHA}" ]; then
    export GIT_COMMIT_SHA="${GITHUB_SHA}"
elif [ ! -z "${APPVEYOR_REPO_COMMIT}" ]; then
    export GIT_COMMIT_SHA="${APPVEYOR_REPO_COMMIT}"
elif [ ! -z "${CIRRUS_CHANGE_IN_REPO}" ]; then
    export GIT_COMMIT_SHA="${CIRRUS_CHANGE_IN_REPO}"
fi

if [ ! -z "${GITHUB_REF_NAME}" ]; then
    export GIT_BRANCH_NAME="${GITHUB_REF_NAME}"
elif [ ! -z "${APPVEYOR_REPO_BRANCH}" ]; then
    export GIT_BRANCH_NAME="${APPVEYOR_REPO_BRANCH}"
elif [ ! -z "${CIRRUS_BRANCH}" ]; then
    export GIT_BRANCH_NAME="${CIRRUS_BRANCH}"
fi

git clone https://github.com/webcamoid/DeployTools.git

export WINEPREFIX=/opt/.wine
export PATH="${PWD}/.local/bin:${PATH}"
export INSTALL_PREFIX=${PWD}/webcamoid-data-${COMPILER}-${TARGET_ARCH}
export PACKAGES_DIR=${PWD}/webcamoid-packages/widows-${COMPILER}-${TARGET_ARCH}
export BUILD_PATH=${PWD}/build-${COMPILER}-${TARGET_ARCH}
export PYTHONPATH="${PWD}/DeployTools"

cat << EOF > package_info_strip.conf
[System]
stripCmd = ${TARGET_ARCH}-w64-mingw32-strip
EOF

cat << EOF > force_plugins_copy.conf
[GStreamer]
haveGStreamer = true
EOF

python DeployTools/deploy.py \
    -d "${INSTALL_PREFIX}" \
    -c "${BUILD_PATH}/package_info.conf" \
    -c "${BUILD_PATH}/package_info_windows.conf" \
    -c "${PWD}/package_info_strip.conf" \
    -c "${PWD}/force_plugins_copy.conf" \
    -o "${PACKAGES_DIR}"

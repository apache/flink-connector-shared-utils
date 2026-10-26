#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "${SCRIPT_DIR}/_init.sh"
source "${SCRIPT_DIR}/_utils.sh"

###########################

check_variables_set ATR_UID

ATR_HOST=${ATR_HOST:-releases.apache.org}

###########################

function check_rsync {
  # ATR rejects the arguments that macOS's built-in openrsync sends
  if rsync --version 2>&1 | grep -q openrsync; then
    echo "openrsync is not supported by ATR. Install rsync, for example with 'brew install rsync'."
    exit 1
  fi
}

function upload_source_release {
  cd ${SOURCE_DIR}
  project=${PROJECT:-${PWD##*/}}
  version=$(get_pom_version)

  echo "Uploading source release v${version} to the ${project} ${version} draft on ${ATR_HOST}"
  echo "To revert this step, delete the files on the release's Compose page on https://${ATR_HOST}"

  rsync -av -e 'ssh -p 2222' "${ARTIFACTS_DIR}/" "${ATR_UID}@${ATR_HOST}:/${project}/${version}/"

  rm -rf ${ARTIFACTS_DIR}
}

(check_rsync)
(create_source_release)
(upload_source_release)

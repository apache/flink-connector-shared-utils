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
#

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "${SCRIPT_DIR}/_init.sh"
source "${SCRIPT_DIR}/_utils.sh"

###########################

check_variables_set RC_NUM

###########################

function deploy_source_release {
  cd ${SOURCE_DIR}
  project=${PROJECT:-${PWD##*/}}
  version=$(get_pom_version)-rc${RC_NUM}

  release=${project}-${version}

  echo "Deploying source release v${version}"
  echo "To revert this step, run 'svn delete ${SVN_DEV_DIR}/${release} --message \"[Revert] Delete ${SVN_DEV_DIR}/${release}\"'"

  svn_dir=${RELEASE_DIR}/svn
  rm -rf ${svn_dir}
  mkdir -p ${svn_dir}
  cd ${svn_dir}

  svn checkout ${SVN_DEV_DIR} --depth=immediates
  cd flink
  mkdir ${release}
  mv ${ARTIFACTS_DIR}/* ${release}
  svn add ${release}
  svn commit -m "Add ${release}"

  cd ${RELEASE_DIR}
  rm -rf ${svn_dir}
}

(create_source_release)
(deploy_source_release)

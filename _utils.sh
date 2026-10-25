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

function check_variables_set {
  any_missing=false

  for variable in "$@"
  do
    if [ -z "${!variable:-}" ]; then
      echo "${variable} was not set."
      any_missing=true
    fi
  done

  if [ ${any_missing} == true ]; then
    exit 1
  fi
}

function create_pristine_source {
  source_dir=$1
  release_dir=$2

  clone_dir="${release_dir}/tmp-clone"
  clean_dir="${release_dir}/tmp-clean-clone"
  rm -rf ${clone_dir}
  rm -rf ${clean_dir}
  # create a temporary git clone to ensure that we have a pristine source release
  git clone "${source_dir}" "${clone_dir}"

  rsync -a \
    --exclude ".git" --exclude ".gitignore" --exclude ".gitattributes" --exclude ".gitmodules" --exclude ".github" \
    --exclude ".idea" --exclude "*.iml" \
    --exclude ".DS_Store" \
    --exclude ".asf.yaml" \
    --exclude "target"  \
    --exclude "tools/releasing/shared" \
    "${clone_dir}/" "${clean_dir}"

  rm -rf "${clone_dir}"

  echo "${clean_dir}"
}

function get_pom_version {
  local version
  local version_pattern='^[0-9]+(\.[0-9]+)*(-[0-9A-Za-z.]+)*$'
  set +u
  version=$(${MVN} help:evaluate -Dexpression="project.version" -q -DforceStdout) || {
    echo "Maven failed to read the project version." >&2
    exit 1
  }
  set -u
  if [[ ! ${version} =~ ${version_pattern} ]]; then
    echo "Unexpected project version '${version}'." >&2
    exit 1
  fi
  echo "${version}"
}

function set_pom_version {
  new_version=$1

  ${MVN} org.codehaus.mojo:versions-maven-plugin:2.8.1:set -DnewVersion=${new_version} -DgenerateBackupPoms=false --quiet
}

function is_flink_version_set_in_pom {
  local version
  local version_pattern='^[0-9]+(\.[0-9]+)*(-[0-9A-Za-z.]+)*$'
  set +u
  version=$(${MVN} help:evaluate -Dexpression="flink.version" -q -DforceStdout) || {
    echo "Maven failed to read flink.version." >&2
    exit 1
  }
  if [[ ${version} =~ ${version_pattern} ]]; then
    echo "true"
  elif [[ -z ${version} || ${version} == "null object or invalid expression" ]]; then
    echo "false"
  else
    echo "Unexpected flink.version '${version}'." >&2
    exit 1
  fi
  set -u
}
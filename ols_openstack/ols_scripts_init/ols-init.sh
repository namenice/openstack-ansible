#!/usr/bin/env bash
# Copyright 2014, Rackspace US, Inc.
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

## Shell Opts ----------------------------------------------------------------

set -e -u -x
set -o pipefail

## Functions -----------------------------------------------------------------

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))
export OA_DIR=$(readlink -f "$SCRIPT_PATH"/../../openstack-ansible)
export WORKSPACE_DIR=$(readlink -f "$SCRIPT_PATH"/../config-openstack)
export BASE_DIR=$(readlink -f "$SCRIPT_PATH"/../)
#export ANSIBLE_ROLE_FILE=$(readlink -f "$BASE_DIR"/ansible-role-requirements.yml  )

echo "ANSIBLE_ROLE_FILE: "
echo ${ANSIBLE_ROLE_FILE}

source ${BASE_DIR}/ols_scripts_init/functions.sh

export OSA_CLONE_DIR="$(pwd)/openstack-ansible"
## Vars ----------------------------------------------------------------------

# Set the role fetch mode to any option [galaxy, git-clone]
export ANSIBLE_ROLE_FETCH_MODE=${ANSIBLE_ROLE_FETCH_MODE:-galaxy}

## Main ----------------------------------------------------------------------

# Check the openstack-ansible submodule status
check_submodule_status

sudo apt update
sudo apt install python-pip
pip install --upgrade pip
pip install pyyaml

# Merge OSA and custom ansible role
${SCRIPT_PATH}/update-yaml.py -l ${ANSIBLE_ROLE_FILE} "${WORKSPACE_DIR}/ansible-role-requirements.yml" "${OA_DIR}/ansible-role-requirements.yml"

# Create symlink
if [[ ! -d /etc/openstack_deploy ]]; then
  ln -s ${WORKSPACE_DIR}/ /etc/openstack_deploy
fi


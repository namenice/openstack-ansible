#!/bin/bash

export SCRIPT_PATH=$(dirname  $(readlink -f -- "$0"))
export ANSIBLE_ROLE_FILE=$(readlink -f "$SCRIPT_PATH"/../ansible-role-requirements.yml  )
echo $SCRIPT_PATH

unset SCRIPT_PATH

#!/usr/bin/env bash

ShellKit_ROOT=${BASH_SOURCE[0]%/*}
if [[ "${ShellKit_ROOT}" == "${BASH_SOURCE[0]}" ]]; then
    ShellKit_ROOT=$(pwd)
else
    ShellKit_ROOT=$(realpath "${ShellKit_ROOT}")
fi
declare -rx ShellKit_ROOT

declare -rx ShellKit_Version=v24.06.16

declare -rx ShellKit_TEMP=${ShellKit_TEMP:-/tmp}

source "${ShellKit_ROOT}/ShellKit_assert_env.sh"
source "${ShellKit_ROOT}/ShellKit_console_codes.sh"
source "${ShellKit_ROOT}/ShellKit_log.sh"
source "${ShellKit_ROOT}/ShellKit_common.sh"

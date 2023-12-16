#!/usr/bin/env bash

function _sleep() {
    local ti=$1
    echo "sleep ${ti}"
    /usr/bin/sleep "${ti}"
}

################################################################################

declare -a ShellKit_ENV_lst=()

# shellcheck disable=SC2034
declare -a ShellKit_ENV_DATE=(DATE /usr/bin/date --version)
ShellKit_ENV_lst+=(ShellKit_ENV_DATE[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_TPUT=(TPUT /usr/bin/tput -V)
ShellKit_ENV_lst+=(ShellKit_ENV_TPUT[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_SLEEP=(SLEEP _sleep)
ShellKit_ENV_lst+=(ShellKit_ENV_SLEEP[@])

################################################################################

# echo "AssertEnv following (${BASH_SOURCE[0]})"
for ShellKit_ENV in "${ShellKit_ENV_lst[@]}"; do
    ShellKit_assert_env "${ShellKit_ENV}"
done; unset ShellKit_ENV

unset ShellKit_ENV_lst

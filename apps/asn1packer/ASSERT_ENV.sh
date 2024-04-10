#!/usr/bin/env bash

################################################################################

declare -a ShellKit_ENV_lst=()

# shellcheck disable=SC2034
declare -a ShellKit_ENV_SED=(SED /usr/bin/sed --version)
ShellKit_ENV_lst+=(ShellKit_ENV_SED[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_AWK=(AWK /usr/bin/awk --version)
ShellKit_ENV_lst+=(ShellKit_ENV_AWK[@])

################################################################################

# echo "AssertEnv following (${BASH_SOURCE[0]})"
for ShellKit_ENV in "${ShellKit_ENV_lst[@]}"; do
    ShellKit_assert_env "${ShellKit_ENV}"
done; unset ShellKit_ENV

unset ShellKit_ENV_lst

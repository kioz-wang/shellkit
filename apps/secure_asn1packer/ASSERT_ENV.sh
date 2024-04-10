#!/usr/bin/env bash

################################################################################

declare -a ShellKit_ENV_lst=()

# shellcheck disable=SC2034
declare -a ShellKit_ENV_DIRNAME=(DIRNAME /usr/bin/dirname --version)
ShellKit_ENV_lst+=(ShellKit_ENV_DIRNAME[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_HEAD=(HEAD /usr/bin/head --version)
ShellKit_ENV_lst+=(ShellKit_ENV_HEAD[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_TAIL=(TAIL /usr/bin/tail --version)
ShellKit_ENV_lst+=(ShellKit_ENV_TAIL[@])

################################################################################

# echo "AssertEnv following (${BASH_SOURCE[0]})"
for ShellKit_ENV in "${ShellKit_ENV_lst[@]}"; do
    ShellKit_assert_env "${ShellKit_ENV}"
done; unset ShellKit_ENV

unset ShellKit_ENV_lst

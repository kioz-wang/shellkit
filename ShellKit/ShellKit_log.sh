#!/usr/bin/env bash

if [ -z "${ShellKit_ROOT}" ]; then
    echo "Not Found Env ShellKit_ROOT"
    exit 1
fi

# ShellKit log levels ##########################################################

declare -x SHELLKIT_LOG_DEBUG_ENABLE=false
declare -x SHELLKIT_LOG_VERB_ENABLE=false
declare -x SHELLKIT_LOG_INFO_ENABLE=true
declare -x SHELLKIT_LOG_WARN_ENABLE=true
declare -x SHELLKIT_LOG_ERROR_ENABLE=true

################################################################################

if [ -d "${ShellKit_ROOT}/log" ]; then
    for i in "${ShellKit_ROOT}/log"/ShellKit_*.sh; do
        if [ -r "$i" ]; then
            # shellcheck source=/dev/null
            source "$i"
        fi
    done; unset i
fi

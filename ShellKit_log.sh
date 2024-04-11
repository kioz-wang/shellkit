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

# ShellKit log timestamp #######################################################

declare -x SHELLKIT_LOG_TIMESTAMP="none"  # simple, normal, extend, custom
declare -x SHELLKIT_LOG_TIMESTAMP_PREFIX=
declare -x SHELLKIT_LOG_TIMESTAMP_SUFFIX=' '

function sktimestamp() {
    local -r timestamp=${SHELLKIT_LOG_TIMESTAMP:?}
    local date_format

    case ${timestamp} in
        simple)
            date_format="%T" ;;
        normal)
            date_format="%D %T" ;;
        extend)
            date_format="%D %T.%N" ;;
        custom)
            date_format="${SHELLKIT_LOG_TIMESTAMP_CUSTOM:?}" ;;
        *)
            return 0 ;;
    esac
    ${SKDATE:?} +"${SHELLKIT_LOG_TIMESTAMP_PREFIX}${date_format}${SHELLKIT_LOG_TIMESTAMP_SUFFIX}"
}
declare -frx sktimestamp

################################################################################

if [ -d "${ShellKit_ROOT}/log" ]; then
    for i in "${ShellKit_ROOT}/log"/ShellKit_*.sh; do
        if [ -r "$i" ]; then
            # shellcheck source=/dev/null
            source "$i"
        fi
    done; unset i
fi

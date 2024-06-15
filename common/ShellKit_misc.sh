#!/usr/bin/env bash

#######################################
# Generate a random integer with a closed range
# Arguments:
#   -n  the minimum of the range (mustn't less than 0)
#   -x  the maximum of the range (mustn't less than 1)
#   -d  the length of the range (mustn't less than 2 or greater than 32768)
#   -o  (default is false) output more information because it's not called in
# the command expansion
# Outputs:
#   write to stdout without newline when it's called in the command expansion
#######################################
function ShellKit_get_random() {
    local -i min
    local -i max
    local -i delta
    local flag_nonexpan=false
    
    unset OPTIND; while getopts ":n:x:d:o" opt; do
        case ${opt} in
            n)
                min=${OPTARG}
                ((min < 0)) && return "${SHELLKIT_RET_INVPARAM}"
                ;;
            x)
                max=${OPTARG}
                ((max < 1)) && return "${SHELLKIT_RET_INVPARAM}"
                ;;
            d)
                delta=${OPTARG}
                ((delta < 2)) && return "${SHELLKIT_RET_INVPARAM}"
                ;;
            o)
                flag_nonexpan=true ;;
            \?)
                return "${SHELLKIT_RET_INVPARAM}"
                ;;
        esac
    done; unset opt; shift $((OPTIND - 1))

    local -i value
    if [[ -n "${min}" && -n "${max}" ]]; then
        ((max <= min)) && return "${SHELLKIT_RET_INVPARAM}"
        ((delta = max - min + 1))
    elif [[ -z "${min}" && -n "${max}" ]]; then
        if [[ -n "${delta}" ]]; then
            ((min = max - (delta - 1)))
            ((min < 0)) && return "${SHELLKIT_RET_INVPARAM}"
        else
            ((delta = max + 1))
            ((min = 0))
        fi
    elif [[ -z "${max}" ]]; then
        ((max = ${min:=0} + (${delta:=32768} - 1)))
    fi
    ((delta > 32768)) && return "${SHELLKIT_RET_INVPARAM}"
    ((value = RANDOM % delta + min))
    if ${flag_nonexpan}; then
        ${ECHO} "Generate ${value} from [${min},${max}]"
    else
        ${ECHO} -n ${value}
    fi
}
declare -frx ShellKit_get_random

#######################################
# Retry a given times over a given timeout until the command is executed
# successfully
# Arguments:
#   -t  the number of times (default is 0xffffffff)
#   -s  the timeout of retry (default is 0xffffffff)
#   -g  sleep for a few seconds before retrying (default is 0)
#   -d  randomly sleep for a few more seconds (mustn't less than 2 or greater
# than 32768)
#   ... the command and its arguments
#######################################
function ShellKit_wait_for() {
    local -i rcount=0xffffffff
    local -i rtimeout=0xffffffff
    local -i gap_second=0
    local -i gap_delta

    unset OPTIND; while getopts ":t:s:g:d:" opt; do
        case ${opt} in
            t)
                rcount=${OPTARG} ;;
            s)
                rtimeout=${OPTARG} ;;
            g)
                gap_second="${OPTARG}"
                ((gap_second < 0)) && return "${SHELLKIT_RET_INVPARAM}"
                ;;
            d)
                gap_delta="${OPTARG}"
                ((gap_delta < 2)) && return "${SHELLKIT_RET_INVPARAM}"
                ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return "${SHELLKIT_RET_INVPARAM}"
                ;;
        esac
    done; unset opt; shift $((OPTIND - 1))
    typeset -r rcount rtimeout gap_second gap_delta

    local -i ret=${SHELLKIT_RET_SUCCESS}
    local -i sleep_second=${gap_second}
    local -i count=0
    local -i future=$(($(${DATE} +%-s) + rtimeout))
    local flag_timeout=false
    while true; do
        "$@"
        ret=$?
        ((ret == 0)) && return "${SHELLKIT_RET_SUCCESS}"
        (($(${DATE} +%-s) >= future)) && flag_timeout=true
        if ((count >= rcount)) || ${flag_timeout}; then
            if ${flag_timeout}; then
                skechoe "[${rcount}:${count}] Fail to execute {$*} (${ret}), timeout(${rtimeout}s)"
            else
                skechoe "[${rcount}:${count}] Fail to execute {$*} (${ret})"
            fi
            return "${SHELLKIT_RET_WAITOUT}"
        fi
        if [[ -n "${gap_delta}" ]]; then
            sleep_second=$(ShellKit_get_random -n ${gap_second} -d ${gap_delta})
        fi
        skechow "[${rcount}:${count}] Fail to execute {$*} (${ret}), retry after ${sleep_second}s"
        ((++count))
        ${SLEEP} ${sleep_second}
    done
}
declare -frx ShellKit_wait_for

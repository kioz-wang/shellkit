#!/usr/bin/env bash

declare -r app=aging:demo

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP=extend

declare control_file="${ShellKit_TEMP}/${app/:/.}.$$.control"
declare flag_yes_break=false
declare flag_no__break=false

unset OPTIND; while getopts ":ync:" opt; do
    case ${opt} in
        y)
            flag_yes_break=true
            flag_no__break=false
            ;;
        n)
            flag_no__break=true
            flag_yes_break=false
            ;;
        c)
            control_file=${OPTARG} ;;
        \?)
            skechoe "Invalid Option: -${OPTARG}"
            return 1
            ;;
    esac
done; unset opt; shift $((OPTIND - 1))
typeset -r flag_yes_break flag_no__break control_file

skechod "params:"
skechod "  flag_yes_break = ${flag_yes_break}"
skechod "  flag_no__break = ${flag_no__break}"
skechod "  control_file   = ${control_file}"

declare -i ret=${SHELLKIT_RET_SUCCESS}

declare -i aging_count=0
declare -i pause_sleep_arg=0
declare -a record_fail record_succ
declare control_flag_pause=false
declare control_flag_stop=false
declare aging_flag_fatal=false

function control_check() {
    local control_word

    if [[ -r "${control_file}" ]]; then
        control_word=$(${SKCAT} "${control_file}")
        true > "${control_file}"
        if [[ -n "${control_word}" ]]; then
            case "${control_word}" in
                pause)
                    control_flag_pause=true ;;&
                stop)
                    control_flag_stop=true ;;&
                continue)
                    control_flag_pause=false ;;&
                pause|stop|continue)
                    skechov "[ControlCheck] Recive ${control_word}" ;;
                *)
                    skechow "[ControlCheck] Ignore invalid ControlWord: ${control_word}" ;;
            esac
        fi
    fi
    ! ${control_flag_stop}
}

function sleep_in_pause() {
    local -i sleep_arg=$1

    ${SKSLEEP} $((++pause_sleep_arg))
    if ((pause_sleep_arg >= sleep_arg)); then
        ((pause_sleep_arg = 0))
    fi
}

function aging_unit() {
    local -i ret=${SHELLKIT_RET_SUCCESS}
    # shellcheck disable=SC2034
    local -i count_for_wait=RETRY_COUNT_INITIALIZER

    if ((ret == 0)); then
        ShellKit_wait_for -t5 -g1 -d2 true_util_random_retry count_for_wait
        ret=$?
        if ((ret == SHELLKIT_RET_WAITOUT)); then
            skechoe "Fatal from aging unit, and the aging should be stop now!"
            aging_flag_fatal=true
        fi
    fi
    if ((ret == 0)); then
        true_util_random_retry
        ret=$?
    fi
    return ${ret}
}

while true; do
    control_check || break
    if ${control_flag_pause}; then
        sleep_in_pause 5
    else
        skechoi "[AgingLoop][$((++aging_count))] Count"
        aging_unit
        ret=$?
        if ((ret == 0)); then
            record_succ=("${record_succ[@]}" "${aging_count}")
            ${flag_yes_break} && break
        else
            record_fail=("${record_fail[@]}" "${aging_count}")
            skechow "[AgingLoop][$((aging_count))] Fail with ${ret}"
            ${flag_no__break} && break
            ${aging_flag_fatal} && break
        fi
    fi
done

skechoi "[AgingStat] $((aging_count)),succ:${#record_succ[@]},fail:${#record_fail[@]}"
skechov "[AgingStat] Show minority cases:"
if ((${#record_succ[@]} > ${#record_fail[@]})); then
    skechov "[AgingStat] ${record_fail[*]}"
else
    skechov "[AgingStat] ${record_succ[*]}"
fi

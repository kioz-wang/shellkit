#!/usr/bin/env bash

ShellKit_ROOT=${ShellKit_ROOT:-"${BASH_SOURCE[0]%/*}/../../ShellKit"}
# shellcheck source=../../ShellKit/ShellKit_init.sh
source "${ShellKit_ROOT}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
# SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
# SHELLKIT_LOG_DEBUG_ENABLE=true

source "${BASH_SOURCE[0]%/*}/ASSERT_ENV.sh"

declare -r app=color_alarm

# shellcheck disable=SC2155
declare -r STYLE_YEAR=$(ShellKit_ccode_SGR_Color256 -f -r 160 -g 160 -b 160 && ShellKit_ccode_SGR_Style italic)
# shellcheck disable=SC2155
declare -r STYLE_MONTH=$(ShellKit_ccode_SGR_Color256 -f -r 180 -g 180 -b 180 && ShellKit_ccode_SGR_Style italic && ShellKit_ccode_SGR_Style underscore)
# shellcheck disable=SC2155
declare -r STYLE_DAY=$(ShellKit_ccode_SGR_Color256 -f -r 220 -g 220 -b 220 && ShellKit_ccode_SGR_Style italic && ShellKit_ccode_SGR_Style underline)
# shellcheck disable=SC2155
declare -r STYLE_WEEK=$(ShellKit_ccode_SGR_Color blue && ShellKit_ccode_SGR_Color256 -f -r255 -g255)
# shellcheck disable=SC2155
declare -r STYLE_HOUR=$(ShellKit_ccode_SGR_Color256 -r60 -g50 -b15 && ShellKit_ccode_SGR_Color256 -f -r195 -g205 -b210)
# shellcheck disable=SC2155
declare -r STYLE_MINUTE=$(ShellKit_ccode_SGR_Color256 -r30 -g15 -b50 && ShellKit_ccode_SGR_Color256 -f -r225 -g210 -b205)
# shellcheck disable=SC2155
declare -r STYLE_SECOND=$(ShellKit_ccode_SGR_Color256 -r10 -g30 -b40 && ShellKit_ccode_SGR_Color256 -f -r245 -g225 -b215 && ShellKit_ccode_SGR_Style blink)
# shellcheck disable=SC2155
declare -r STYLE_MESSAGE=$(ShellKit_ccode_SGR_Color -f red && ShellKit_ccode_SGR_Style bold && ShellKit_ccode_SGR_Style underscore)
# shellcheck disable=SC2155
declare -r STYLE_RESET=$(ShellKit_ccode_SGR_Reset)

declare -i timer_start
declare -i timer_clock
declare year month day week hour minute second

function blink_screen() {
    local -ir times=$1
    local -r timegap=$2

    for ((i=0; i<times; i++)); do
        ShellKit_ccode_CSI_PriMode -e scnm
        ${SLEEP} "${timegap}"
        ShellKit_ccode_CSI_PriMode -ex scnm
        ${SLEEP} "${timegap}"
    done; unset i
}

function set_start() {
    timer_start=$(${DATE} +%s)
}

function set_clock() {
    local -i clock_second=$1
    ((timer_clock = timer_start + clock_second))
}

function check_clock() {
    local -i timer_now
    timer_now=$(${DATE} +%s)
    [[ timer_now -ge timer_clock ]]
}

# Dprecated
function _get_now() {
    local -n year_ref=$1
    local -n month_ref=$2
    local -n day_ref=$3
    local -n week_ref=$4
    local -n hour_ref=$5
    local -n minute_ref=$6
    local -n second_ref=$7

    # shellcheck disable=SC2034
    read -rs year_ref month_ref day_ref week_ref    \
        hour_ref minute_ref second_ref              \
        <<< "$(${DATE} +"%Y %m %d %a %H %M %S")"
}

# Dprecated
function _show_date_time() {
    local -i top_left_x top_left_y
    ShellKit_ccode_CSI_MoveSaveRest -e
    ShellKit_ccode_CSI_MoveXY -e -x999 -y1
    ShellKit_ccode_CSI_Move -e -o15 left
    ShellKit_ccode_CSI_CPR top_left_x top_left_y
    ${ECHO} -en "${STYLE_YEAR}${year}${STYLE_RESET} "
    ${ECHO} -en "${STYLE_MONTH}${month}${STYLE_RESET} "
    ${ECHO} -en "${STYLE_DAY}${day}${STYLE_RESET}"
    ShellKit_ccode_CSI_MoveXY -e -x $((top_left_x-1)) -y $((top_left_y += 1))
    ${ECHO} -en "${STYLE_WEEK}${week}${STYLE_RESET} "
    ${ECHO} -en "${STYLE_HOUR}${hour}${STYLE_RESET}:"
    ${ECHO} -en "${STYLE_MINUTE}${minute}${STYLE_RESET}:"
    ${ECHO} -en "${STYLE_SECOND}${second}${STYLE_RESET}"
    ShellKit_ccode_CSI_MoveSaveRest -e restore
}

# Dprecated
function __show_date_time() {
    local -i top_left_x top_left_y
    ShellKit_ccode_CSI_MoveSaveRest -e
    ShellKit_ccode_CSI_MoveXY -e -x999 -y1
    ShellKit_ccode_CSI_Move -e -o15 left
    ShellKit_ccode_CSI_CPR top_left_x top_left_y
    ${ECHO} -en "$(
        ${DATE} +"${STYLE_YEAR}%Y${STYLE_RESET} ${STYLE_MONTH}%m${STYLE_RESET} ${STYLE_DAY}%d${STYLE_RESET}"
    )"
    ShellKit_ccode_CSI_MoveXY -e -x $((top_left_x-1)) -y $((top_left_y += 1))
    ${ECHO} -en "$(
        ${DATE} +"${STYLE_WEEK}%a${STYLE_RESET} ${STYLE_HOUR}%H${STYLE_RESET}:${STYLE_MINUTE}%M${STYLE_RESET}:${STYLE_SECOND}%S${STYLE_RESET}"
    )"
    ShellKit_ccode_CSI_MoveSaveRest -e restore
}

function show_date_time() {
    local -i top_left_x top_left_y
    top_left_x=$(${TPUT} cols)
    top_left_y=1
    ShellKit_ccode_CSI_MoveSaveRest -e
    ShellKit_ccode_CSI_MoveXY -e -x $((top_left_x-15)) -y $((top_left_y)) "$(
        ShellKit_ccode_CSI_Erase -e whole "$(
            ${DATE} +"${STYLE_YEAR}%Y${STYLE_RESET} ${STYLE_MONTH}%m${STYLE_RESET} ${STYLE_DAY}%d${STYLE_RESET}"
        )"
    )"
    ShellKit_ccode_CSI_MoveXY -e -x $((top_left_x-16)) -y $((top_left_y+1)) "$(
        ShellKit_ccode_CSI_Erase -e whole "$(
            ${DATE} +"${STYLE_WEEK}%a${STYLE_RESET} ${STYLE_HOUR}%H${STYLE_RESET}:${STYLE_MINUTE}%M${STYLE_RESET}:${STYLE_SECOND}%S${STYLE_RESET}"
        )"
    )"
    ShellKit_ccode_CSI_MoveSaveRest -e restore
}

function main() {
    assert_params_num_min "${app}" "{sec} [{msg}]" 1 $#

    declare -r isec=$1
    shift
    if [ $# -ne 0 ]; then
        declare -r imsg="$*"
    else
        declare -r imsg="Alert!"
    fi

    skechod "[${app}] params:"
    skechod "[${app}]     isec  = ${isec}"
    skechod "[${app}]     imsg  = ${imsg}"
    skechod

    local -i ret=${SHELLKIT_RET_SUCCESS}

    set_start
    set_clock "${isec}"

    until check_clock; do
        ${SLEEP} 0.1
        # _get_now year month day week hour minute second
        # _show_date_time
        show_date_time
    done
    ${ECHO} -e "${STYLE_MESSAGE}${imsg}${STYLE_RESET}"
    blink_screen 5 0.02

    return ${ret}
}

main "$@"

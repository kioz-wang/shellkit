#!/usr/bin/env bash

if [[ -z "${ShellKit_ROOT}" ]]; then
    echo "Not Found Env ShellKit_ROOT"
    exit 1
fi

################################################################################

function ShellKit_dump_argv() {
    for arg in "$@"; do
        echo "\"${arg}\""
    done
}

function ShellKit_assert_env() {
    local einfo=$1

    local ename="${!einfo:0:1}"
    local epath="${!einfo:1:1}"
    local echeck=("${!einfo:2}")
    local epath_base=${epath##*/}

    # shellcheck disable=SC2034
    local -r STY_VERB="\e[2m"
    # shellcheck disable=SC2034
    local -r STY_INFO="\e[92m"
    # shellcheck disable=SC2034
    local -r STY_WARN="\e[48;2;255;255;0m"
    local -r STY_ERRO="\e[41m"
    local -r STY_REST="\e[0m"

    # echo -e "${STY_VERB}einfo(${ename}) Assertting path(${epath}),check(${echeck[*]})${STY_REST}"
    if [[ -v "${ename}" ]]; then
        # echo -e "${STY_VERB}einfo(${ename}) Already path(${!ename})${STY_REST}"
        # shellcheck disable=SC2163
        export "${ename}"
        return
    fi
    if [[ -z ${epath_base} ]]; then
        echo -e "${STY_ERRO}FailAssertEnv(${ename}) Invalid path(${epath})${STY_REST}"
        exit 1
    fi
    if [[ ${epath} == "${epath_base}" ]]; then
        epath=$(command -v "${epath_base}")
        if [[ -z ${epath} ]]; then
            echo -e "${STY_ERRO}FailAssertEnv(${ename}) Detect(${epath_base}) notfound${STY_REST}"
            exit 1
        fi
        if [[ ${epath} = alias* ]]; then
            echo -e "${STY_ERRO}FailAssertEnv(${ename}) Detect(${epath_base}) alias found in path(${epath}), should absolute${STY_REST}"
            exit 1
        fi
        # echo -e "${STY_INFO}einfo(${ename}) Detect(${epath_base}) path(${epath})${STY_REST}"
    fi
    export "${ename}"="${epath}"
    if ((${#echeck[@]} == 0)) ; then
        # echo -e "${STY_WARN}einfo(${ename}) Check(Skip) force to path(${epath})${STY_REST}"
        return
    fi
    if ! ${epath} "${echeck[@]}" &> /dev/null; then
        echo -e "${STY_ERRO}FailAssertEnv(${ename}) Check(${echeck[*]}) fail at path(${epath})${STY_REST}"
        exit 1
    fi
}

################################################################################

if [[ -n "${ShellKit_APPDIR}" ]]; then
    if [[ -r "${ShellKit_APPDIR}/ASSERT_ENV.sh" ]]; then
        # shellcheck source=/dev/null
        source "${ShellKit_APPDIR}/ASSERT_ENV.sh"
    fi
fi

################################################################################

declare -a ShellKit_ENV_lst=()

# shellcheck disable=SC2034
declare -a ShellKit_ENV_ECHO=(ECHO echo)
ShellKit_ENV_lst+=(ShellKit_ENV_ECHO[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_CAT=(CAT cat)
ShellKit_ENV_lst+=(ShellKit_ENV_CAT[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_SLEEP=(SLEEP sleep)
ShellKit_ENV_lst+=(ShellKit_ENV_SLEEP[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_OPENSSL=(OPENSSL openssl version)
ShellKit_ENV_lst+=(ShellKit_ENV_OPENSSL[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_RM=(RM rm)
ShellKit_ENV_lst+=(ShellKit_ENV_RM[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_WC=(WC wc --version)
ShellKit_ENV_lst+=(ShellKit_ENV_WC[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_LS=(LS /usr/bin/ls)
ShellKit_ENV_lst+=(ShellKit_ENV_LS[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_MV=(MV mv)
ShellKit_ENV_lst+=(ShellKit_ENV_MV[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_GREP=(GREP /usr/bin/grep --version)
ShellKit_ENV_lst+=(ShellKit_ENV_GREP[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_DATE=(DATE /usr/bin/date --version)
ShellKit_ENV_lst+=(ShellKit_ENV_DATE[@])

################################################################################

# echo "AssertEnv following (${BASH_SOURCE[0]})"
for ShellKit_ENV in "${ShellKit_ENV_lst[@]}"; do
    ShellKit_assert_env "${ShellKit_ENV}"
done; unset ShellKit_ENV

unset ShellKit_ENV_lst

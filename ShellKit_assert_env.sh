#!/usr/bin/env bash

if [ -z "${ShellKit_ROOT}" ]; then
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
    # echo "einfo name(${ename}) path(${epath}) check(${echeck[*]})"
    if [ -v "${ename}" ]; then
        # echo "einfo Already (${ename}=${!ename})"
        # shellcheck disable=SC2163
        export "${ename}"
        return
    fi
    export "${ename}"="${epath}"
    if [ ${#echeck[@]} -eq 0 ] ; then
        # echo "einfo Force (${ename}=${epath})"
        return
    fi
    if ! "${epath}" "${echeck[@]}" &> /dev/null; then
        echo "FailAssertEnv (${ename}=${epath}) ${echeck[*]}"
        exit 1
    fi
}

################################################################################

if [ -n "${ShellKit_APPDIR}" ]; then
    if [ -r "${ShellKit_APPDIR}/ASSERT_ENV.sh" ]; then
        # shellcheck source=/dev/null
        source "${ShellKit_APPDIR}/ASSERT_ENV.sh"
    fi
fi

################################################################################

declare -a ShellKit_ENV_lst=()

# shellcheck disable=SC2034
declare -a ShellKit_ENV_ECHO=(ECHO /usr/bin/echo --version)
ShellKit_ENV_lst+=(ShellKit_ENV_ECHO[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_CAT=(CAT /usr/bin/cat --version)
ShellKit_ENV_lst+=(ShellKit_ENV_CAT[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_SLEEP=(SLEEP /usr/bin/sleep --version)
ShellKit_ENV_lst+=(ShellKit_ENV_SLEEP[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_OPENSSL=(OPENSSL /usr/bin/openssl version)
ShellKit_ENV_lst+=(ShellKit_ENV_OPENSSL[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_SED=(SED /usr/bin/sed --version)
ShellKit_ENV_lst+=(ShellKit_ENV_SED[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_AWK=(AWK /usr/bin/awk --version)
ShellKit_ENV_lst+=(ShellKit_ENV_AWK[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_BASENAME=(BASENAME /usr/bin/basename --version)
ShellKit_ENV_lst+=(ShellKit_ENV_BASENAME[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_DIRNAME=(DIRNAME /usr/bin/dirname --version)
ShellKit_ENV_lst+=(ShellKit_ENV_DIRNAME[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_REALPATH=(REALPATH /usr/bin/realpath --version)
ShellKit_ENV_lst+=(ShellKit_ENV_REALPATH[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_RM=(RM /usr/bin/rm --version)
ShellKit_ENV_lst+=(ShellKit_ENV_RM[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_WC=(WC /usr/bin/wc --version)
ShellKit_ENV_lst+=(ShellKit_ENV_WC[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_LS=(LS /usr/bin/ls --version)
ShellKit_ENV_lst+=(ShellKit_ENV_LS[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_PRINTF=(PRINTF /usr/bin/printf --version)
ShellKit_ENV_lst+=(ShellKit_ENV_PRINTF[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_HEAD=(HEAD /usr/bin/head --version)
ShellKit_ENV_lst+=(ShellKit_ENV_HEAD[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_TAIL=(TAIL /usr/bin/tail --version)
ShellKit_ENV_lst+=(ShellKit_ENV_TAIL[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_GREP=(GREP /usr/bin/grep --version)
ShellKit_ENV_lst+=(ShellKit_ENV_GREP[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_DD=(DD /usr/bin/dd --version)
ShellKit_ENV_lst+=(ShellKit_ENV_DD[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_MV=(MV /usr/bin/mv --version)
ShellKit_ENV_lst+=(ShellKit_ENV_MV[@])

################################################################################

# echo "AssertEnv following (${BASH_SOURCE[0]})"
for ShellKit_ENV in "${ShellKit_ENV_lst[@]}"; do
    ShellKit_assert_env "${ShellKit_ENV}"
done; unset ShellKit_ENV

unset ShellKit_ENV_lst
#!/usr/bin/env bash

if [[ -z "${ShellKit_ROOT}" ]]; then
    echo "Not Found Env ShellKit_ROOT"
    exit 1
fi

# ShellKit return values #######################################################

declare -irx SHELLKIT_RET_SUCCESS=0
declare -i ShellKit_ret_i=0
declare -irx SHELLKIT_RET_UNSUPPORT=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_INVPARAM=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_NOTFOUND=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_NOMEMORY=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_OUTOFRANGE=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_SUBPROCESS=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_FILEIO=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_CYBER_CRYPTO=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_CRYPTO_SYM=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_CRYPTO_ASYM=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_CYBER_AUTHEN=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_CYBER_INTEGR=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_CYBER_NON_RE=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_ASN1=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_MISC=$((++ShellKit_ret_i))
declare -irx SHELLKIT_RET_BE_CAREFUL=$((++ShellKit_ret_i))
unset ShellKit_ret_i

################################################################################

if [[ -d "${ShellKit_ROOT}/common" ]]; then
    for i in "${ShellKit_ROOT}/common"/ShellKit_*.sh; do
        if [[ -r "$i" ]]; then
            # shellcheck source=/dev/null
            source "$i"
        fi
    done; unset i
fi

################################################################################

if [[ -v app ]] && [[ -n "${ShellKit_APPDIR}" ]]; then
    if [[ -r "${ShellKit_APPDIR}/PROVIDER.sh" ]]; then
        # shellcheck source=/dev/null
        source "${ShellKit_APPDIR}/PROVIDER.sh"
    fi
fi

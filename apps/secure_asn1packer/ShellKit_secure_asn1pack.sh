#!/usr/bin/env bash

declare -r app=sasn1pack

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP=normal

assert_params_num_min "${app}" "{ifile0} [{ifile1} ...] {ofile}" 2 $#

declare -ir ifile_num=$#-1
declare -a ifile_lst=("$@")
declare -r ofile=${ifile_lst[-1]}
unset "ifile_lst[-1]"

assert_files_r "${ifile_lst[@]}"

skechod "params:"
for (( i=0; i < ifile_num; i++ )); do
    skechod "    ifile[$i] = ${ifile_lst[$i]}"
done; unset i
skechod "    ofile    = ${ofile}"
skechod

declare -i ret=${SHELLKIT_RET_SUCCESS}

declare _ld_raw_file="${ofile}.raw"
declare _ld_sign_file="${ofile}.sign"
declare -a _ld_ifile_y_lst
for (( i=0; i < ifile_num; i++ )); do
    _ld_ifile_y_lst[i]="${ifile_lst[i]}.y"
done; unset i

if ((ret == 0)); then
    for (( i = 0; i < ifile_num && ret == 0; i++ )); do
        if secure_asn1packer_encrypt "${ifile_lst[i]}" "${_ld_ifile_y_lst[i]}"; then
            skechov "encrypt ${ifile_lst[i]} to ${_ld_ifile_y_lst[i]}"
        else
            skechoe "fail to encrypt ${ifile_lst[i]} to ${_ld_ifile_y_lst[i]} ($?)"
            ret=${SHELLKIT_RET_CYBER_CRYPTO}
        fi
    done; unset i
fi

if ((ret == 0)); then
    if "${ShellKit_ROOT}/apps/asn1packer/ShellKit_asn1pack.sh" "${_ld_ifile_y_lst[@]}" "${_ld_raw_file}"; then
        skechov "asn1pack ${_ld_raw_file}"
    else
        skechoe "fail to asn1pack ${_ld_raw_file} ($?)"
        ret=${SHELLKIT_RET_SUBPROCESS}
    fi
fi

if ((ret == 0)); then
    if secure_asn1packer_sign "${_ld_raw_file}" "${_ld_sign_file}"; then
        skechov "generate the signature(${_ld_sign_file}) of ${_ld_raw_file}"
    else
        skechoe "fail to generate the signature(${_ld_sign_file}) of ${_ld_raw_file} ($?)"
        ret=${SHELLKIT_RET_CYBER_AUTHEN}
    fi
fi

if ((ret == 0)); then
    secure_asn1packer_join_signature "${_ld_raw_file}" "${_ld_sign_file}" "${ofile}"
    skechov "generate ${ofile} from ${ifile_lst[*]}"
fi

for _file in "${_ld_ifile_y_lst[@]}" "${_ld_raw_file}" "${_ld_sign_file}"; do
    if file_access_r "${_file}"; then
        ${RM} "${_file}"
        skechov "remove ${_file}"
    fi
done; unset _file

exit ${ret}

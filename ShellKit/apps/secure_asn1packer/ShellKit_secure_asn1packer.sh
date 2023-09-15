#!/usr/bin/env bash

ShellKit_ROOT=${ShellKit_ROOT:-"${BASH_SOURCE[0]%/*}/../.."}
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

source "${BASH_SOURCE[0]%/*}/PROVIDER.sh"

declare -r app=secure_asn1packer

assert_params_num_min "${app}" "{ifile0} [{ifile1} ...] {ofile}" 2 $#

declare -ir ifile_num=$#-1
declare -a ifile_lst=("$@")
declare -r ofile=${ifile_lst[-1]}
unset "ifile_lst[-1]"

assert_files_r "${ifile_lst[@]}"

skechod "[${app}] params:"
for (( i=0; i < ifile_num; i++ )); do
    skechod "[${app}]     ifile[$i] = ${ifile_lst[$i]}"
done; unset i
skechod "[${app}]     ofile    = ${ofile}"
skechod

declare -r _raw_file="${ofile}.raw"
declare -r _sign_file="${ofile}.sign"

declare -i ret=${SHELLKIT_RET_SUCCESS}

declare -a ifile_y_lst
for (( i=0; i < ifile_num; i++ )); do
    ifile_y_lst[i]="${ifile_lst[i]}.y"
done; unset i

if [ ${ret} -eq 0 ]; then
    for (( i = 0; i < ifile_num && ret == 0; i++ )); do
        if secure_asn1packer_encrypt "${ifile_lst[i]}" "${ifile_y_lst[i]}"; then
            skechov "[${app}] encrypt ${ifile_lst[i]} to ${ifile_y_lst[i]}"
        else
            skechoe "[${app}] fail to encrypt ${ifile_lst[i]} to ${ifile_y_lst[i]} ($?)"
            ret=${SHELLKIT_RET_CYBER_CRYPTO}
        fi
    done; unset i
fi

if [ ${ret} -eq 0 ]; then
    if "${ShellKit_ROOT}/apps/asn1packer/ShellKit_asn1packer.sh" "${ifile_y_lst[@]}" "${_raw_file}"; then
        skechov "[${app}] asn1pack ${_raw_file}"
    else
        skechoe "[${app}] fail to asn1pack ${_raw_file} ($?)"
        ret=${SHELLKIT_RET_SUBPROCESS}
    fi
fi

if [ ${ret} -eq 0 ]; then
    if secure_asn1packer_sign "${_raw_file}" "${_sign_file}"; then
        skechov "[${app}] generate the signature(${_sign_file}) of ${_raw_file}"
    else
        skechoe "[${app}] fail to generate the signature(${_sign_file}) of ${_raw_file} ($?)"
        ret=${SHELLKIT_RET_CYBER_AUTHEN}
    fi
fi

if [ ${ret} -eq 0 ]; then
    secure_asn1packer_join_signature "${_raw_file}" "${_sign_file}" "${ofile}"
    skechov "[${app}] generate ${ofile} from ${ifile_lst[*]}"
fi

for _file in "${ifile_y_lst[@]}" "${_raw_file}" "${_sign_file}"; do
    if file_access_r "${_file}"; then
        ${RM} "${_file}"
        skechov "[${app}] remove ${_file}"
    fi
done; unset _file

exit ${ret}

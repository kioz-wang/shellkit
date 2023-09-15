#!/usr/bin/env bash

ShellKit_ROOT=${ShellKit_ROOT:-"${BASH_SOURCE[0]%/*}/../.."}
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

source "${BASH_SOURCE[0]%/*}/PROVIDER.sh"

declare -r app=secure_asn1unpacker

assert_params_num_min "${app}" "{ifile} [{odir}]" 1 $#

declare -r ifile=$1
if [ $# -ge 2 ]; then
    declare -r odir=$2
else
    declare -r odir=${PWD}
fi

assert_files_r "${ifile}"
assert_dirs_w "${odir}"

skechod "[${app}] params:"
skechod "[${app}]     ifile  = ${ifile}"
skechod "[${app}]     odir   = ${odir}"
skechod

declare -r _raw_file="${ifile}.raw"
declare -r _sign_file="${ifile}.sign"

declare -i ret=${SHELLKIT_RET_SUCCESS}

declare -i ifile_num
declare -a ifile_y_lst

if [ ${ret} -eq 0 ]; then
    secure_asn1packer_split_signature "${ifile}" "${_raw_file}" "${_sign_file}"
    skechov "[${app}] split ${ifile} to ${_raw_file}($(file_get_size "${_raw_file}")) and ${_sign_file}($(file_get_size "${_sign_file}"))"
fi

if [ ${ret} -eq 0 ]; then
    if secure_asn1packer_verify "${_raw_file}" "${_sign_file}"; then
        skechov "[${app}] verify the signature(${_sign_file}) of ${_raw_file}"
    else
        skechoe "[${app}] fail to verify the signature(${_sign_file}) of ${_raw_file} ($?)"
        ret=${SHELLKIT_RET_CYBER_AUTHEN}
    fi
fi

if [ ${ret} -eq 0 ]; then
    if "${ShellKit_ROOT}/apps/asn1packer/ShellKit_asn1unpacker.sh" "${_raw_file}" "${odir}"; then
        skechov "[${app}] asn1unpack ${_raw_file}"
    else
        skechoe "[${app}] fail to asn1unpack ${_raw_file} ($?)"
        ret=${SHELLKIT_RET_SUBPROCESS}
    fi
fi

if [ ${ret} -eq 0 ]; then
    ifile_num=$(${CAT} "${odir}/ifile_num")
    for (( i=0; i < ifile_num; i++ )); do
        ${MV} "${odir}/ifile$i" "${odir}/ifile${i}.y"
        ${RM} "${odir}/ifile${i}.hash"
        ifile_y_lst[i]="${odir}/ifile${i}.y"
    done; unset i
fi

if [ ${ret} -eq 0 ]; then
    for ifile_y in "${ifile_y_lst[@]}"; do
        if secure_asn1packer_decrypt "${ifile_y}" "${ifile_y%.y}"; then
            skechov "[${app}] decrypt ${ifile_y} to ${ifile_y%.y}"
        else
            skechoe "[${app}] fail to decrypt ${ifile_y} to ${ifile_y%.y} ($?)"
            ret=${SHELLKIT_RET_CYBER_CRYPTO}
        fi
    done; unset ifile_y
fi

for _file in "${ifile_y_lst[@]}" "${_raw_file}" "${_sign_file}"; do
    if file_access_r "${_file}"; then
        ${RM} "${_file}"
        skechov "[${app}] remove ${_file}"
    fi
done; unset _file

exit ${ret}

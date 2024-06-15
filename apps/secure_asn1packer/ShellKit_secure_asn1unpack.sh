#!/usr/bin/env bash

declare -r app=sasn1unpack

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP=normal

assert_params_num_min "${app}" "{ifile} [{odir}]" 1 $#

declare -r ifile=$1
if (($# >= 2)); then
    declare -r odir=$2
else
    declare -r odir=${PWD}
fi

assert_files_r "${ifile}"
assert_dirs_w "${odir}"

skechod "params:"
skechod "    ifile  = ${ifile}"
skechod "    odir   = ${odir}"
skechod

declare -i ret=${SHELLKIT_RET_SUCCESS}

declare _ld_raw_file="${ifile}.raw"
declare _ld_sign_file="${ifile}.sign"
declare -a _ld_ifile_y_lst

declare -i ifile_num

if ((ret == 0)); then
    secure_asn1packer_split_signature "${ifile}" "${_ld_raw_file}" "${_ld_sign_file}"
    skechov "split ${ifile} to ${_ld_raw_file}($(file_get_size "${_ld_raw_file}")) and ${_ld_sign_file}($(file_get_size "${_ld_sign_file}"))"
fi

if ((ret == 0)); then
    if secure_asn1packer_verify "${_ld_raw_file}" "${_ld_sign_file}"; then
        skechov "verify the signature(${_ld_sign_file}) of ${_ld_raw_file}"
    else
        skechoe "fail to verify the signature(${_ld_sign_file}) of ${_ld_raw_file} ($?)"
        ret=${SHELLKIT_RET_CYBER_AUTHEN}
    fi
fi

if ((ret == 0)); then
    if "${ShellKit_ROOT}/apps/asn1packer/ShellKit_asn1unpack.sh" "${_ld_raw_file}" "${odir}"; then
        skechov "asn1unpack ${_ld_raw_file}"
    else
        skechoe "fail to asn1unpack ${_ld_raw_file} ($?)"
        ret=${SHELLKIT_RET_SUBPROCESS}
    fi
fi

if ((ret == 0)); then
    ifile_num=$(${CAT} "${odir}/ifile_num")
    for (( i=0; i < ifile_num; i++ )); do
        ${MV} "${odir}/ifile$i" "${odir}/ifile${i}.y"
        ${RM} "${odir}/ifile${i}.hash"
        _ld_ifile_y_lst[i]="${odir}/ifile${i}.y"
    done; unset i
fi

if ((ret == 0)); then
    for ifile_y in "${_ld_ifile_y_lst[@]}"; do
        if secure_asn1packer_decrypt "${ifile_y}" "${ifile_y%.y}"; then
            skechov "decrypt ${ifile_y} to ${ifile_y%.y}"
        else
            skechoe "fail to decrypt ${ifile_y} to ${ifile_y%.y} ($?)"
            ret=${SHELLKIT_RET_CYBER_CRYPTO}
        fi
    done; unset ifile_y
fi

for _file in "${_ld_ifile_y_lst[@]}" "${_ld_raw_file}" "${_ld_sign_file}"; do
    if file_access_r "${_file}"; then
        ${RM} "${_file}"
        skechov "remove ${_file}"
    fi
done; unset _file

exit ${ret}

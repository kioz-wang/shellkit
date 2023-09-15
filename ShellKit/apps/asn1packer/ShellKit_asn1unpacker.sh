#!/usr/bin/env bash

ShellKit_ROOT=${ShellKit_ROOT:-"${BASH_SOURCE[0]%/*}/../.."}
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

declare -r app=asn1unpacker

assert_params_num_min "${app}" "{ifile} [{odir} [{idx}]]" 1 $#

declare -r ifile=$1
if [ $# -ge 2 ]; then
    declare -r odir=$2
else
    declare -r odir=${PWD}
fi
if [ $# -ge 3 ]; then
    declare -ir idx=$3
fi

assert_files_r "${ifile}"
assert_dirs_w "${odir}"

skechod "[${app}] params:"
skechod "[${app}]     ifile  = ${ifile}"
skechod "[${app}]     odir   = ${odir}"
if [ -v idx ]; then
    skechod "[${app}]     idx    = ${idx}"
else
    skechod "[${app}]     idx    = ALL"
fi
skechod

declare -r _parse_file=parse.asn1

declare -i ret=${SHELLKIT_RET_SUCCESS}

declare -i ifile_num

function parse_dump_by_idx() {
    local -ir parse_idx=$1

    local parse_result_length
    local parse_result_hash
    local check_hash

    parse_result_length=$(${GREP} -A 3 ifile${parse_idx} "${_parse_file}" | ${SED} -n 2p)
    parse_result_length=0x${parse_result_length##*:}
    skechod "[${app}] [parse]:${parse_idx} length ${parse_result_length}"

    parse_result_hash=$(${GREP} -A 3 ifile${parse_idx} "${_parse_file}" | ${SED} -n 3p)
    parse_result_hash=${parse_result_hash##*:}
    ${ECHO} -n "${parse_result_hash}" > "${odir}/ifile${parse_idx}.hash"
    skechov "[${app}] [parse]:${parse_idx} hash ${parse_result_hash} -> ${odir}/ifile${parse_idx}.hash"

    ${GREP} -A 3 "prim: IA5STRING[ ]*:ifile${parse_idx}" "${_parse_file}" | ${SED} -n 4p \
        | ${SED} 's/^.*OCTET STRING[ ]*://g'    \
        | file_base64 d > "${odir}/ifile${parse_idx}"
    skechov "[${app}] [parse]:${parse_idx} context -> ${odir}/ifile${parse_idx}"

    check_hash=$(file_get_hash "${odir}/ifile${parse_idx}" sha256 | ${SED} 's/[a-z]/\u&/g')
    if [ "${check_hash}" = "${parse_result_hash}" ]; then
        skechod "[${app}] [parse]:${parse_idx} integrity check pass"
    else
        skechoe "[${app}] [parse]:${parse_idx} integrity fail with ${check_hash}"
        # shellcheck disable=SC2086
        return ${SHELLKIT_RET_CYBER_INTEGR}
    fi
}

if [ ${ret} -eq 0 ]; then
    if ${OPENSSL} asn1parse -inform der -in "${ifile}" > "${_parse_file}"; then
        skechov "[${app}] generate asn1 formatter: ${_parse_file}"
    else
        skechov "[${app}] fail to generate asn1 formatter: ${_parse_file} ($?)"
        ret=${SHELLKIT_RET_ASN1}
    fi
fi

if [ ${ret} -eq 0 ]; then
    ifile_num=$(${GREP} -c "prim: IA5STRING[ ]*:ifile" "${_parse_file}")
    ${ECHO} -n ${ifile_num} > "${odir}/ifile_num"
    # shellcheck disable=SC2086
    if [ -v idx ] && [ ${idx} -ge ${ifile_num} ]; then
        skechoe "[${app}] out of index ${idx}, total ${ifile_num}"
        ret=${SHELLKIT_RET_OUTOFRANGE}
    fi
fi

if [ ${ret} -eq 0 ]; then
    if [ -v idx ]; then
        parse_dump_by_idx "${idx}"
        ret=$?
    else
        for (( i=0; i < ifile_num; i++ )); do
            parse_dump_by_idx $i
            ret=$?
            [ ${ret} -ne 0 ] && break
        done; unset i
    fi
fi

if file_access_r "${_parse_file}"; then
    ${RM} "${_parse_file}"
    skechov "[${app}] remove asn1 formatter: ${_parse_file}"
fi

exit ${ret}
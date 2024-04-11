#!/usr/bin/env bash

declare -r app=asn1pack

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
# SHELLKIT_LOG_DEBUG_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP=normal

declare -r _gd_conf_file=${ShellKit_TEMP}/config.asn1

assert_params_num_min "${app}" "{ifile0} [{ifile1} ...] {ofile}" 2 $#

declare -ir ifile_num=$#-1
declare -a ifile_lst=("$@")
declare -r ofile=${ifile_lst[-1]}
unset "ifile_lst[-1]"

assert_files_r "${ifile_lst[@]}"

skechod "[${app}] params:"
for (( i=0; i < ifile_num; i++ )); do
    skechod "[${app}]     ifile[$i] = ${ifile_lst[i]}"
done; unset i
skechod "[${app}]     ofile    = ${ofile}"
skechod

declare -i ret=${SHELLKIT_RET_SUCCESS}

${SKCAT} > "${_gd_conf_file}" <<EOF
asn1=SEQ:ofile

[ofile]
EOF
skechod "[${app}] write asn1 formatter head-part into ${_gd_conf_file}"

for (( i=0; i < ifile_num; i++ )); do
    ${SKECHO} "ifile$i = SEQ:ifile$i" >> "${_gd_conf_file}"
done; unset i
skechod "[${app}] write asn1 formatter ofile-part into ${_gd_conf_file}"

for (( i=0; i < ifile_num; i++ )); do
    ${SKCAT} >> "${_gd_conf_file}" <<EOF

[ifile$i]
name    = IA5STRING:ifile$i
length  = INT:$(file_get_size "${ifile_lst[i]}")
hash    = INT:0x$(file_get_hash "${ifile_lst[i]}" sha256)
content = OCT:$(file_base64 e "${ifile_lst[i]}")
EOF
done; unset i
skechod "[${app}] write asn1 formatter ifiles-part into ${_gd_conf_file}"

skechov "[${app}] generate asn1 formatter: ${_gd_conf_file}"

if ((ret == 0)); then
    if ${SKOPENSSL} asn1parse -genconf "${_gd_conf_file}" -out "${ofile}" -noout; then
        skechov "[${app}] generate ${ofile} packed ${ifile_lst[*]}"
    else
        skechov "[${app}] fail to generate ${ofile} packed ${ifile_lst[*]} ($?)"
        ret=${SHELLKIT_RET_ASN1}
    fi
fi

if file_access_r "${_gd_conf_file}"; then
    ${SKRM} "${_gd_conf_file}"
    skechov "[${app}] remove asn1 formatter: ${_gd_conf_file}"
fi

exit ${ret}

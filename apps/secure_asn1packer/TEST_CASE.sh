#!/usr/bin/env bash

declare -r tcase="tcase(sasn1packer)"

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

assert_dirs_w "${ShellKit_APPDIR}/TEST/"
cd "${ShellKit_APPDIR}/TEST/" || exit 1

if ../ShellKit_secure_asn1pack.sh bin0 bin1 bin2 bin\ name\ include\ spaces binpack; then
    skechoi "[${tcase}] secure pack binpack"
else
    skechow "[${tcase}] fail to secure pack binpack ($?)"
    exit 1
fi

if dir_access_w dump_binpack; then
    rm -rf dump_binpack
fi
mkdir dump_binpack
if ../ShellKit_secure_asn1unpack.sh binpack dump_binpack; then
    skechoi "[${tcase}] secure unpack binpack to dump_binpack"
else
    skechow "[${tcase}] fail to secure unpack binpack to dump_binpack ($?)"
    exit 1
fi

skechoi
skechoi "[${tcase}] the number of binaries inside binpack is $(${SKCAT} dump_binpack/ifile_num)"
skechoi "[${tcase}] check the md5 of source and pack-unpack binaries"
skechoi "[${tcase}] source:bin0                       = $(file_get_hash bin0 md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack/ifile0   = $(file_get_hash dump_binpack/ifile0 md5)"
skechoi "[${tcase}] source:bin1                       = $(file_get_hash bin1 md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack/ifile1   = $(file_get_hash dump_binpack/ifile1 md5)"
skechoi "[${tcase}] source:bin2                       = $(file_get_hash bin2 md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack/ifile2   = $(file_get_hash dump_binpack/ifile2 md5)"
skechoi "[${tcase}] source:bin name include spaces    = $(file_get_hash bin\ name\ include\ spaces md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack/ifile3   = $(file_get_hash dump_binpack/ifile3 md5)"
skechoi

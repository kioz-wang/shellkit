#!/usr/bin/env bash

declare -r tcase="tcase(asn1packer)"

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

assert_dirs_w "${ShellKit_APPDIR}/TEST/"
cd "${ShellKit_APPDIR}/TEST/" || exit 1

if ../ShellKit_asn1packer.sh bin0 bin1 bin2 bin\ name\ include\ spaces binpack_012space; then
    skechoi "[${tcase}] pack binpack_012space"
else
    skechow "[${tcase}] fail to pack binpack_012space ($?)"
    exit 1
fi

if ../ShellKit_asn1packer.sh  bin7 bin6 binpack_76; then
    skechoi "[${tcase}] pack binpack_76"
else
    skechow "[${tcase}] fail to pack binpack_76 ($?)"
    exit 1
fi

if dir_access_w dump_binpack_012space; then
    rm -rf dump_binpack_012space
fi
mkdir dump_binpack_012space
if ../ShellKit_asn1unpacker.sh binpack_012space dump_binpack_012space 2; then
    skechoi "[${tcase}] unpack idx 2 of binpack_012space to dump_binpack_012space"
else
    skechow "[${tcase}] fail to unpack idx 2 of binpack_012space to dump_binpack_012space ($?)"
    exit 1
fi

if dir_access_w dump_binpack_76; then
    rm -rf dump_binpack_76
fi
mkdir dump_binpack_76
if ../ShellKit_asn1unpacker.sh binpack_76 dump_binpack_76; then
    skechoi "[${tcase}] unpack all of binpack_76 to dump_binpack_76"
else
    skechow "[${tcase}] fail to unpack all of binpack_76 to dump_binpack_76 ($?)"
    exit 1
fi

skechoi
skechoi "[${tcase}] the number of binaries inside binpack_012space is $(${CAT} dump_binpack_012space/ifile_num)"
skechoi "[${tcase}] check the md5 of source and pack-unpack binaries indexed 2"
skechoi "[${tcase}] source:bin2                               = $(file_get_hash bin2 md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack_012space/ifile2  = $(file_get_hash dump_binpack_012space/ifile2 md5)"
skechoi

skechoi
skechoi "[${tcase}] the number of binaries inside binpack_76 is $(${CAT} dump_binpack_76/ifile_num)"
skechoi "[${tcase}] check the md5 of source and pack-unpack binaries"
skechoi "[${tcase}] source:bin7                           = $(file_get_hash bin7 md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack_76/ifile0    = $(file_get_hash dump_binpack_76/ifile0 md5)"
skechoi "[${tcase}] source:bin6                           = $(file_get_hash bin6 md5)"
skechoi "[${tcase}] pack-unpack:dump_binpack_76/ifile1    = $(file_get_hash dump_binpack_76/ifile1 md5)"
skechoi

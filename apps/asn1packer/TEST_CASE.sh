#!/usr/bin/env bash

# shellcheck disable=SC2034
declare -r app="tcase(asn1packer)"

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP_PREFIX='<'
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP_SUFFIX='>'
# shellcheck disable=SC2034
SHELLKIT_LOG_TIMESTAMP=extend

assert_dirs_w "${ShellKit_APPDIR}/TEST/"
cd "${ShellKit_APPDIR}/TEST/" || exit 1

if ../ShellKit_asn1pack.sh bin0 bin1 bin2 bin\ name\ include\ spaces binpack_012space; then
    skechoi "pack binpack_012space"
else
    skechow "fail to pack binpack_012space ($?)"
    exit 1
fi

if ../ShellKit_asn1pack.sh  bin7 bin6 binpack_76; then
    skechoi "pack binpack_76"
else
    skechow "fail to pack binpack_76 ($?)"
    exit 1
fi

if dir_access_w dump_binpack_012space; then
    rm -rf dump_binpack_012space
fi
mkdir dump_binpack_012space
if ../ShellKit_asn1unpack.sh binpack_012space dump_binpack_012space 2; then
    skechoi "unpack idx 2 of binpack_012space to dump_binpack_012space"
else
    skechow "fail to unpack idx 2 of binpack_012space to dump_binpack_012space ($?)"
    exit 1
fi

if dir_access_w dump_binpack_76; then
    rm -rf dump_binpack_76
fi
mkdir dump_binpack_76
if ../ShellKit_asn1unpack.sh binpack_76 dump_binpack_76; then
    skechoi "unpack all of binpack_76 to dump_binpack_76"
else
    skechow "fail to unpack all of binpack_76 to dump_binpack_76 ($?)"
    exit 1
fi

skechoi
skechoi "the number of binaries inside binpack_012space is $(${SKCAT} dump_binpack_012space/ifile_num)"
skechoi "check the md5 of source and pack-unpack binaries indexed 2"
skechoi "source:bin2                               = $(file_get_hash bin2 md5)"
skechoi "pack-unpack:dump_binpack_012space/ifile2  = $(file_get_hash dump_binpack_012space/ifile2 md5)"
skechoi

skechoi
skechoi "the number of binaries inside binpack_76 is $(${SKCAT} dump_binpack_76/ifile_num)"
skechoi "check the md5 of source and pack-unpack binaries"
skechoi "source:bin7                           = $(file_get_hash bin7 md5)"
skechoi "pack-unpack:dump_binpack_76/ifile0    = $(file_get_hash dump_binpack_76/ifile0 md5)"
skechoi "source:bin6                           = $(file_get_hash bin6 md5)"
skechoi "pack-unpack:dump_binpack_76/ifile1    = $(file_get_hash dump_binpack_76/ifile1 md5)"
skechoi

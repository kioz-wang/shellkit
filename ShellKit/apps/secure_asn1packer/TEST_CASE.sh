#!/usr/bin/env bash

ShellKit_ROOT=${ShellKit_ROOT:-"${BASH_SOURCE[0]%/*}/../.."}
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

assert_dirs_w "${BASH_SOURCE[0]%/*}/TEST/"
cd "${BASH_SOURCE[0]%/*}/TEST/" || exit 1

declare -r app=CASE::sasn1packer

if ../ShellKit_secure_asn1packer.sh bin0 bin1 bin2 bin\ name\ include\ spaces binpack; then
    skechoi "[${app}] secure pack binpack"
else
    skechow "[${app}] fail to secure pack binpack ($?)"
    exit 1
fi

if dir_access_w dump_binpack; then
    rm -rf dump_binpack
fi
mkdir dump_binpack
if ../ShellKit_secure_asn1unpacker.sh binpack dump_binpack; then
    skechoi "[${app}] secure unpack binpack to dump_binpack"
else
    skechow "[${app}] fail to secure unpack binpack to dump_binpack ($?)"
    exit 1
fi

skechoi
skechoi "[${app}] the number of binaries inside binpack is $(${CAT} dump_binpack/ifile_num)"
skechoi "[${app}] check the md5 of source and pack-unpack binaries"
skechoi "[${app}] source:bin0                       = $(file_get_hash bin0 md5)"
skechoi "[${app}] pack-unpack:dump_binpack/ifile0   = $(file_get_hash dump_binpack/ifile0 md5)"
skechoi "[${app}] source:bin1                       = $(file_get_hash bin1 md5)"
skechoi "[${app}] pack-unpack:dump_binpack/ifile1   = $(file_get_hash dump_binpack/ifile1 md5)"
skechoi "[${app}] source:bin2                       = $(file_get_hash bin2 md5)"
skechoi "[${app}] pack-unpack:dump_binpack/ifile2   = $(file_get_hash dump_binpack/ifile2 md5)"
skechoi "[${app}] source:bin name include spaces    = $(file_get_hash bin\ name\ include\ spaces md5)"
skechoi "[${app}] pack-unpack:dump_binpack/ifile3   = $(file_get_hash dump_binpack/ifile3 md5)"
skechoi

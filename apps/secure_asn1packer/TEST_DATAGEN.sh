#!/usr/bin/env bash

declare -r tgen="tgen(sasn1packer)"

ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
SHELLKIT_LOG_DEBUG_ENABLE=true

assert_dirs_w "${ShellKit_APPDIR}/TEST/"
cd "${ShellKit_APPDIR}/TEST/" || exit 1

for (( i=0; i<3; i++ )); do
    bin_sz=0x$(${OPENSSL} rand -hex 3)
    ${OPENSSL} rand -out bin$i $((bin_sz))
    skechoi "[${tgen}] generate random binary: bin$i with size ${bin_sz}"
done; unset i

bin_sz=0x$(${OPENSSL} rand -hex 3)
${OPENSSL} rand -out "bin name include spaces" $((bin_sz))
skechoi "[${tgen}] generate random binary: \"bin name include spaces\" with size ${bin_sz}"

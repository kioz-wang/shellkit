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

declare -r app=DATAGEN::sasn1packer

for (( i=0; i<3; i++ )); do
    bin_sz=0x$(${OPENSSL} rand -hex 3)
    ${OPENSSL} rand -out bin$i $((bin_sz))
    skechoi "[${app}] generate random binary: bin$i with size ${bin_sz}"
done; unset i

bin_sz=0x$(${OPENSSL} rand -hex 3)
${OPENSSL} rand -out "bin name include spaces" $((bin_sz))
skechoi "[${app}] generate random binary: \"bin name include spaces\" with size ${bin_sz}"

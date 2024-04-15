#!/usr/bin/env bash

# shellcheck disable=SC2034
declare -ir RETRY_COUNT_INITIALIZER=0xffffffff
declare -i _ld_retry_count=RETRY_COUNT_INITIALIZER

function true_util_random_retry() {
    if (($# == 1)); then
        local -n count_ref=$1
    else
        local -n count_ref=_ld_retry_count
    fi

    if ((count_ref == 0xffffffff)); then
        count_ref=$(ShellKit_get_random -n2 -d5)
    fi
    if ((count_ref == 0)); then
        count_ref=$(ShellKit_get_random -n2 -d5)
        skechoi "success from aging objects"
        return 0
    fi
    skechov "some messages from aging objects"
    skechoe "some errors from aging objects (${count_ref})"
    ((--count_ref))
    return ${count_ref}
}

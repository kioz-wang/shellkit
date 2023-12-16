#!/usr/bin/env bash

DATE=${DATE:-/usr/bin/date}
function CHECK_DATE() {
    ${DATE} --version > /dev/null
}

TPUT=${TPUT:-/usr/bin/tput}
function CHECK_TPUT() {
    ${TPUT} -V > /dev/null
}

################################################################################

true    \
    && CHECK_DATE        \
    && CHECK_TPUT        \
    || exit 1

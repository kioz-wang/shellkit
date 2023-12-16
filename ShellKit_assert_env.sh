#!/usr/bin/env bash

export CAT=${CAT:-/usr/bin/cat}
function CHECK_CAT() {
    ${CAT} --version > /dev/null
}

export ECHO=${ECHO:-/usr/bin/echo}
function CHECK_ECHO() {
    ${ECHO} --version > /dev/null
}

export OPENSSL=${OPENSSL:-/usr/bin/openssl}
function CHECK_OPENSSL() {
    ${OPENSSL} version > /dev/null
}

export SED=${SED:-/usr/bin/sed}
function CHECK_SED() {
    ${SED} --version > /dev/null
}

export AWK=${AWK:-/usr/bin/awk}
function CHECK_AWK() {
    ${AWK} --version > /dev/null
}

export BASENAME=${BASENAME:-/usr/bin/basename}
function CHECK_BASENAME() {
    ${BASENAME} --version > /dev/null
}

export DIRNAME=${DIRNAME:-/usr/bin/dirname}
function CHECK_DIRNAME() {
    ${DIRNAME} --version > /dev/null
}

export REALPATH=${REALPATH:-/usr/bin/realpath}
function CHECK_REALPATH() {
    ${REALPATH} --version > /dev/null
}

export RM=${RM:-/usr/bin/rm}
function CHECK_RM() {
    ${RM} --version > /dev/null
}

export WC=${WC:-/usr/bin/wc}
function CHECK_WC() {
    ${WC} --version > /dev/null
}

export LS=${LS:-/usr/bin/ls}
function CHECK_LS() {
    ${LS} --version > /dev/null
}

export PRINTF=${PRINTF:-/usr/bin/printf}
function CHECK_PRINTF() {
    ${PRINTF} --version > /dev/null
}

export HEAD=${HEAD:-/usr/bin/head}
function CHECK_HEAD() {
    ${HEAD} --version > /dev/null
}

export TAIL=${TAIL:-/usr/bin/tail}
function CHECK_TAIL() {
    ${TAIL} --version > /dev/null
}

export GREP=${GREP:-/usr/bin/grep}
function CHECK_GREP() {
    ${GREP} --version > /dev/null
}

export DD=${DD:-/usr/bin/dd}
function CHECK_DD() {
    ${DD} --version > /dev/null
}

export MV=${MV:-/usr/bin/mv}
function CHECK_MV() {
    ${MV} --version > /dev/null
}

export SLEEP=${SLEEP:-/usr/bin/sleep}
function CHECK_SLEEP() {
    ${SLEEP} --version > /dev/null
}

################################################################################

true    \
    && CHECK_CAT        \
    && CHECK_ECHO       \
    && CHECK_OPENSSL    \
    && CHECK_SED        \
    && CHECK_AWK        \
    && CHECK_BASENAME   \
    && CHECK_DIRNAME    \
    && CHECK_REALPATH   \
    && CHECK_RM         \
    && CHECK_WC         \
    && CHECK_LS         \
    && CHECK_PRINTF     \
    && CHECK_HEAD       \
    && CHECK_TAIL       \
    && CHECK_GREP       \
    && CHECK_DD         \
    && CHECK_MV         \
    && CHECK_SLEEP      \
    || exit 1

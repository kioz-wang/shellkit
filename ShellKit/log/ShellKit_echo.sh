#!/usr/bin/env bash

# ShellKit log::echo styles ####################################################

# shellcheck disable=SC2155
declare -rx SHELLKIT_STYLE_ECHOI=$(ShellKit_ccode_SGR_Color -f green)
declare -rx SHELLKIT_STYLE_ECHOV=$(ShellKit_ccode_SGR_Color -f blue)
declare -rx SHELLKIT_STYLE_ECHOW=$(ShellKit_ccode_SGR_Color256 -f -r 255 -g 255)
declare -rx SHELLKIT_STYLE_ECHOE=$(ShellKit_ccode_SGR_Color -f red && ShellKit_ccode_SGR_Style blink)
declare -rx SHELLKIT_STYLE_ECHOD=$(ShellKit_ccode_SGR_Color256 -f -r 160 -g 160 -b 160)
declare -rx SHELLKIT_STYLE_RESET=$(ShellKit_ccode_SGR_Reset)

################################################################################

function skechoi() {
    if ${SHELLKIT_LOG_INFO_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOI}[I] $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechoi

function skechov() {
    if ${SHELLKIT_LOG_VERB_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOV}[V] $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechov

function skechow() {
    if ${SHELLKIT_LOG_WARN_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOW}[W] $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechow

function skechoe() {
    if ${SHELLKIT_LOG_ERROR_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOE}[E] $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechoe

function skechod() {
    if ${SHELLKIT_LOG_DEBUG_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOD}[D] $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechod

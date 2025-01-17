#!/usr/bin/env bash

# ShellKit log::echo styles ####################################################

# shellcheck disable=SC2155
declare -rx SHELLKIT_STYLE_ECHOI=$(ShellKit_ccode_SGR_Color -f green)
declare -rx SHELLKIT_STYLE_ECHOV=$(ShellKit_ccode_SGR_Color -f blue)
declare -rx SHELLKIT_STYLE_ECHOW=$(ShellKit_ccode_SGR_Color256 -f -r 255 -g 255)
declare -rx SHELLKIT_STYLE_ECHOE=$(ShellKit_ccode_SGR_Color -f red && ShellKit_ccode_SGR_Style bold)
declare -rx SHELLKIT_STYLE_ECHOD=$(ShellKit_ccode_SGR_Color256 -f -r 160 -g 160 -b 160)
declare -rx SHELLKIT_STYLE_RESET=$(ShellKit_ccode_SGR_Reset)

################################################################################

function skechoi() {
    if ${SHELLKIT_LOG_INFO_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOI}$(sktimestamp)[I]${app:+[${app}]} $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechoi

function skechov() {
    if ${SHELLKIT_LOG_VERB_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOV}$(sktimestamp)[V]${app:+[${app}]} $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechov

function skechow() {
    if ${SHELLKIT_LOG_WARN_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOW}$(sktimestamp)$(ShellKit_ccode_SGR_Style blink)[W]$(ShellKit_ccode_SGR_Style -x blink)${app:+[${app}]} $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechow

function skechoe() {
    if ${SHELLKIT_LOG_ERROR_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOE}$(sktimestamp)$(ShellKit_ccode_SGR_Style blink)[E]$(ShellKit_ccode_SGR_Style -x blink)${app:+[${app}]} $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechoe

function skechod() {
    if ${SHELLKIT_LOG_DEBUG_ENABLE}; then
        echo -e "${SHELLKIT_STYLE_ECHOD}$(sktimestamp)[D]${app:+[${app}]} $*${SHELLKIT_STYLE_RESET}"
    fi
}
declare -frx skechod

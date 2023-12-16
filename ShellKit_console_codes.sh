#!/usr/bin/env bash

if [ -z "${ShellKit_ROOT}" ]; then
    echo "Not Found Env ShellKit_ROOT"
    exit 1
fi

################################################################################

#######################################
# Make CSI-sequences (Select Graphic Rendition): reset all attributes to their
# defaults.
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
# Dprecated:
#   use `tput sgr0` instead
#######################################
function ShellKit_ccode_SGR_Reset() {
    local escape=false
    while getopts ":e" opt; do
        case ${opt} in
            e)
                escape=true ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local CSIseq

    CSIseq="\e[0m"

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_SGR_Reset

#######################################
# Make CSI-sequences (Select Graphic Rendition): bright or not, foreground or
# background, 8 Colors
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -f  set foreground (default is background)
#   -b  set bright version
#   color   the name of 8 Colors (pass any invalid name to get the whole valid
# from error message) (default is default)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
# Dprecated:
#   use `tput setab/setaf [0-7]` to set 8-Color for background/foreground instead
#######################################
function ShellKit_ccode_SGR_Color() {
    local -iAr color2int=( [black]=0 [red]=1 [green]=2 [brown]=3 [blue]=4 [magenta]=5 [cyan]=6 [white]=7 [default]=9 )
    
    local foreground=false
    local bright=false
    local escape=false
    while getopts ":fbe" opt; do
        case ${opt} in
            f)
                foreground=true ;;
            b)
                bright=true ;;
            e)
                escape=true ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local color="default"
    if [ $# -ge 1 ]; then
        color=$1
        shift
    fi
    if [ -z "${color2int[${color}]}" ]; then
        echo "NotFound Color ${color} in [${!color2int[*]}]"
        return 1
    fi

    local -i colori=0
    local CSIseq

    if ${foreground}; then colori+=30; else colori+=40; fi
    if [ "${color}" != "default" ] && ${bright}; then colori+=60; fi
    colori+=color2int[${color}]
    CSIseq="\e[${colori}m"

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_SGR_Color

#######################################
# Make CSI-sequences (Select Graphic Rendition): foreground or background, 256
# Colors
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -f  set foreground (default is background)
#   -r  set the value of red (default is zero, range in [0,255])
#   -g  set the value of green (default is zero, range in [0,255])
#   -b  set the value of blue (default is zero, range in [0,255])
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_SGR_Color256() {
    local foreground=false
    local escape=false
    local -i r256=0
    local -i g256=0
    local -i b256=0
    while getopts ":fer:g:b:" opt; do
        case ${opt} in
            f)
                foreground=true ;;
            e)
                escape=true ;;
            r)
                r256=${OPTARG} ;;&
            g)
                g256=${OPTARG} ;;&
            b)
                b256=${OPTARG} ;;&
            r|g|b)
                if [ "${OPTARG}" -lt 0 ] || [ "${OPTARG}" -ge 256 ]; then
                    echo "RGB value ${OPTARG} NotIn [0,255]"
                    return 1
                fi
                ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local -i colori=0
    local CSIseq

    if ${foreground}; then colori+=38; else colori+=48; fi
    CSIseq="\e[${colori};2;${r256};${g256};${b256}m"

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_SGR_Color256

#######################################
# Make CSI-sequences (Select Graphic Rendition): Style
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -x  set off
#   style   the name of style (pass any invalid name to get the whole valid from
# error message) (default is bold)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_SGR_Style() {
    local -iAr style2int=( [bold]=1 [dim]=2 [italic]=3 [underscore]=4 [blink]=5 [reverse]=7 [underline]=21 )
    # shellcheck disable=SC2034
    local -iAr styleoff2int=( [bold]=22 [dim]=22 [italic]=23 [underscore]=24 [blink]=25 [reverse]=27 [underline]=24 )

    local escape=false
    local setoff=false
    while getopts ":ex" opt; do
        case ${opt} in
            e)
                escape=true ;;
            x)
                setoff=true ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local style="bold"
    if [ $# -ge 1 ]; then
        style=$1
        shift
    fi
    if [ -z "${style2int[${style}]}" ]; then
        echo "NotFound style ${style} in [${!style2int[*]}]"
        return 1
    fi
    
    local -i stylei
    local CSIseq

    if ${setoff}; then
        stylei=styleoff2int[${style}];
    else
        stylei=style2int[${style}];
    fi
    CSIseq="\e[${stylei}m"

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_SGR_Style

#######################################
# Make CSI-sequences: Cursor movement based direction
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -s  to column 1 when up/down
#   -o  offset with current position (default is zero)
#   move    the direction of movement (pass any invalid name to get the whole
# valid from error message) (default is right)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_CSI_Move() {
    local escape=false
    local special=false
    local -i offset=0
    while getopts ":eso:" opt; do
        case ${opt} in
            e)
                escape=true ;;
            s)
                special=true ;;
            o)
                offset=${OPTARG} ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local move="right"
    if [ $# -ge 1 ]; then
        move=$1
        shift
    fi

    local action
    local CSIseq

    case ${move} in
        up)
            if ${special}; then
                action=F;
            else
                action=A;
            fi ;;
        down)
            if ${special}; then
                action=E;
            else
                action=B;
            fi ;;
        right)
                action=C ;;
        left)
                action=D ;;
        *)
            echo "NotFound direction ${move} in [up down right left]"
            return 1
            ;;
    esac
    CSIseq="\e[${offset}${action}"

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_CSI_Move

#######################################
# Make CSI-sequences: Absolute cursor movement based coordinate system (origin
# (1,1) is left-top)
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -x  (default is current column) (at least one of -x and -y must appear)
#   -y  (default is current row) (at least one of -x and -y must appear)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
# Dprecated:
#   use `tput cup {row} {column}` to move cursor to ({column},{row}) instead
#######################################
function ShellKit_ccode_CSI_MoveXY() {
    local escape=false
    local -i movex=0
    local -i movey=0

    while getopts ":ex:y:" opt; do
        case ${opt} in
            e)
                escape=true ;;
            x)
                movex=${OPTARG} ;;&
            y)
                movey=${OPTARG} ;;&
            x|y)
                if [ "${OPTARG}" -le 0 ]; then
                    echo "the valud of ${opt} ${OPTARG} NotIn [1,+inf)"
                    return 1
                fi
                ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND
    if [ ${movex} -eq 0 ] && [ ${movey} -eq 0 ]; then
        echo "at least one of -x and -y must appear"
        return 1
    fi

    local CSIseq

    if [ ${movex} -eq 0 ]; then
        CSIseq="\e[${movey}d"
    elif [ ${movey} -eq 0 ]; then
        CSIseq="\e[${movex}G"
    else
        CSIseq="\e[${movey};${movex}H"
    fi

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_CSI_MoveXY

#######################################
# Make CSI-sequences: Save/Restore cursor location
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   action  save/restore (default to save)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
# Dprecated:
#   use `tput sc` to save and use `tput rc` to restore location instead
#######################################
function ShellKit_ccode_CSI_MoveSaveRest() {
    local escape=false
    while getopts ":e" opt; do
        case ${opt} in
            e)
                escape=true ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local action="save"
    if [ $# -ge 1 ]; then
        action=$1
        shift
    fi

    local CSIseq

    if [ "${action}" == "save" ]; then
        CSIseq="\e[s"
    elif [ "${action}" == "restore" ]; then
        CSIseq="\e[u"
    else
        echo "NotFound ${move} in [save restore]"
        return 1
    fi

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_CSI_MoveSaveRest

#######################################
# Make CSI-sequences: Erase display/line/character
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -d  erase display (default to erase line)
#   -b  erase character (priority over -d)
#   -n  the number of characters when erase characters (default is zero)
#   range   the range of erasing (pass any invalid name to get the whole valid
# from error message) (default is from cursor to end)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_CSI_Erase() {
    local -iAr rangedisp2int=( [end]=0 [start]=1 [whole]=2 [scroll]=3 )

    local escape=false
    local object="line"
    local -i number=0
    while getopts ":edbn:" opt; do
        case ${opt} in
            e)
                escape=true ;;
            d)
                if [ ${object} != "character" ]; then
                    object="display"
                fi
                ;;
            b)
                object="character" ;;
            n)
                number=${OPTARG}
                if [ "${OPTARG}" -le 0 ]; then
                    echo "the valud of ${opt} ${OPTARG} NotIn [1,+inf)"
                    return 1
                fi
                ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local -i rangei=0
    local action
    local CSIseq

    if [ ${object} == "character" ]; then
        CSIseq="\e[${number}X"
    else
        local range="end"
        if [ $# -ge 1 ]; then
            range=$1
            shift
        fi
        if [ -z "${rangedisp2int[${range}]}" ]; then
            echo "NotFound range ${range} in [${!rangedisp2int[*]}]"
            return 1
        fi
        rangei=rangedisp2int[${range}]
        if [ ${object} == "line" ]; then
            if [ ${rangei} -eq 3 ]; then
                echo "Invalid range ${range} when object is ${object}"
                return 1
            fi
            action="K"
        else
            action="J"
        fi
        if [ ${rangei} -eq 0 ]; then
            CSIseq="\e[${action}"
        else
            CSIseq="\e[${rangei}${action}"
        fi
    fi

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_CSI_Erase

#######################################
# Make CSI-sequences: Insert or Delete lines or blanks/characters
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -d  delete objects (default to insert objects)
#   -b  operate blanks/characters (default to operate lines)
#   -n  the number of objects (default is zero)
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_CSI_InsDel() {
    local escape=false
    local operate="insert"
    local object="lines"
    local -i number=0
    while getopts ":edbn:" opt; do
        case ${opt} in
            e)
                escape=true ;;
            d)
                operate="delete" ;;
            b)
                object="blanks" ;;
            n)
                number=${OPTARG}
                if [ "${OPTARG}" -le 0 ]; then
                    echo "the valud of ${opt} ${OPTARG} NotIn [1,+inf)"
                    return 1
                fi
                ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local action
    local CSIseq

    if [ ${operate} == "insert" ] && [ ${object} == "lines" ]; then
        action="L"
    elif [ ${operate} == "insert" ] && [ ${object} == "blanks" ]; then
        action="@"
    elif [ ${operate} == "delete" ] && [ ${object} == "lines" ]; then
        action="M"
    elif [ ${operate} == "delete" ] && [ ${object} == "blanks" ]; then
        action="P"
    fi
    CSIseq="\e[${number}${action}"

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_CSI_InsDel

#######################################
# Make ESC- but not CSI-sequences
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   item    Reset(ris)/Linefeed(ind)/Newline(nel)/Reverse linefeed(ri) (pass any
# invalid name to get the whole valid from error message) (default is ris)
#   ... the rest arguments if there be would be showed prefixing the ESC
# sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_ESConly() {
    local -Ar name2char=( [ris]=c [ind]=D [nel]=E [ri]=M )

    local escape=false
    while getopts ":e" opt; do
        case ${opt} in
            e)
                escape=true ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local item="ris"
    if [ $# -ge 1 ]; then
        item=$1
        shift
    fi
    if [ -z "${name2char[${item}]}" ]; then
        echo "NotFound ${item} in [${!name2char[*]}]"
        return 1
    fi

    local ESCseq

    ESCseq="\e${name2char[${item}]}"

    if [ $# -ne 0 ]; then
        echo -ne "${ESCseq}$*"
    else
        if ${escape}; then
            echo -ne "${ESCseq}"
        else
            echo -n "${ESCseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_ESConly

#######################################
# Make CSI-sequences: Report cursor position
# Arguments:
#   x   the variable would be store the x of coordinate
#   y   the variable would be store the y of coordinate
# Outputs:
#   nothing to stdout, using stdin by `read` but
# Dprecated:
#   use `tput lines/cols` to get the number of rows/columns for the current terminal
#######################################
function ShellKit_ccode_CSI_CPR() {
    if [ $# -lt 2 ]; then
        echo "Tell me two variables' name for coordinate"
        return 1
    fi
    local -n CPRx_ref=$1
    local -n CPRy_ref=$2

    local CPRseq="\e[6n"

    echo -ne "${CPRseq}"
    read -rsd \[ _foo
    # shellcheck disable=SC2034
    read -rsd \; CPRy_ref
    # shellcheck disable=SC2034
    read -rsd R CPRx_ref
}
declare -frx ShellKit_ccode_CSI_CPR

#######################################
# Make CSI-sequences: Set/Reset some DEC Private Modes
# Arguments:
#   -e  effective immediately (enable interpretation of the backslash escapes)
#   -x  set off
#   ... the rest arguments if there be would be showed prefixing the
# CSI-sequences that set above
# Outputs:
#   write to stdout without newline
#######################################
function ShellKit_ccode_CSI_PriMode() {
    local -iAr mode2int=( [scnm]=5 [tecm]=25 )

    local escape=false
    local setoff=false
    while getopts ":ex" opt; do
        case ${opt} in
            e)
                escape=true ;;
            x)
                setoff=true ;;
            \?)
                echo "Invalid Option: -${OPTARG}"
                return 1
                ;;
        esac
    done; unset opt
    shift $((OPTIND - 1)); unset OPTIND

    local mode="scnm"
    if [ $# -ge 1 ]; then
        mode=$1
        shift
    fi
    if [ -z "${mode2int[${mode}]}" ]; then
        echo "NotFound mode ${mode} in [${!mode2int[*]}]"
        return 1
    fi
    
    local -i modei
    local CSIseq

    modei=${mode2int[${mode}]}
    if ${setoff}; then
        CSIseq="\e[?${modei}l"
    else
        CSIseq="\e[?${modei}h"
    fi

    if [ $# -ne 0 ]; then
        echo -ne "${CSIseq}$*"
    else
        if ${escape}; then
            echo -ne "${CSIseq}"
        else
            echo -n "${CSIseq}"
        fi
    fi
}
declare -frx ShellKit_ccode_CSI_PriMode

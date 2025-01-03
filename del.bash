#!/bin/bash
shopt -s expand_aliases
alias del='set -f && DelEx';
function DelEx () {
    set +o noglob
    set -o nounset
    local ErrMsg="This function requires arguments."
    local Usage="Usage: del <path> [<name to exclude> <name to exclude> ...]"
    ! (: ${1:?"${ErrMsg}${IFS}${Usage}${IFS}"}) && { set +u; return 1; }
    set +o nounset
    local Path="$1"
    Path="$(realpath -- "$Path")"
    [[ "$Path" == "/" ]] && {
        echo "Cannot execute.";
        return 1;
    }
    local N=2 Arg=() Escaped Args=()
    while [[ "$N" -le "$#" ]]; do
        Arg[$N]="$N"
        Escaped=$(perl -e "print quotemeta('${!Arg[$N]}');")
        Args+=(! -regex ".*/${Escaped}\(/.*\|\)")
       ((N++))
    done
    echo "[Summary]"
    echo -e "Target path: \n  '$Path'"
    [[ -d $Path ]] && {
        [[ $1 =~ ^\.+(/+\.*)*$ ]] || { find "$Path" -xdev -maxdepth 0 -delete 2>/dev/null && return; }
        echo "Name to exclude: ";
        local width Nest;
        width=$((`tput cols`-`tput cols`/3));
        Nest=("${Arg[@]/#/\$\{}");
        eval echo "${Nest[@]/%/@Q\}}" | fold -s -w $width | awk '{print "  " $0}';
        echo -e "\n[Verbose]";
        find "$Path" -xdev -depth ! -path "$Path" -regextype findutils-default "${Args[@]}" -print -delete;
        return;
    }
    [[ -f $Path ]] && {
        find "$Path" -xdev -maxdepth 0 -delete;
        return;
    }
    echo "failed."
    return 255
}

[[ "${BASH_SOURCE[0]}" = "${0}" ]] && EscCMD="exit" || EscCMD="return"
alias 'goto'="$EscCMD " ':eof'="0"
goto :eof

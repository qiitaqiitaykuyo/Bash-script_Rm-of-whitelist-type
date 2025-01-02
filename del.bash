#!/bin/bash
shopt -s expand_aliases
alias del='set -f && DelEx'
function DelEx () {
    set +o noglob
    set -o nounset
    ErrMsg="This function requires arguments."
    Usage="Usage: del <path> [<name to exclude> <name to exclude> ...]"
    ! (: ${1:?"${ErrMsg}${IFS}${Usage}${IFS}"}) && return 1
    Path="$1"
    Path="$(realpath -- "$Path")"
    [[ "$Path" == "/" ]] && {
        echo "Cannot execute.";
        return 1;
    }
    unset Arg Args
    N=2; Arg=(); Args=()
    while [[ "$N" -le "$#" ]]; do
        Arg[$N]="$N"
        Escaped=$(perl -e "print quotemeta('${!Arg[$N]}');")
        Args+=(! -regex ".*/${Escaped}\(/.*\|\)")
       ((N++))
    done
    [[ -d $Path ]] && {
        [[ $1 =~ ^\.+(/+\.*)*$ ]] || { find "$Path" -xdev -maxdepth 0 -delete 2>/dev/null && return; }
        find "$Path" -xdev -depth ! -path "$Path" -regextype findutils-default "${Args[@]}" -delete 2> >(grep -v "Directory not empty" >&2);
        return;
    }
    [[ -f $Path ]] && {
        find "$Path" -xdev -maxdepth 0 -delete;
        return;
    }
    return 255
}

[[ "${BASH_SOURCE[0]}" = "${0}" ]] && EscCMD="exit" || EscCMD="return"
alias 'goto'="$EscCMD " ':eof'="$ExitCODE"
goto :eof

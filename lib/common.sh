#!/bin/sh

if [ "$ENABLE_VERBOSE" = "1" ]
then
    set -x
fi

TOOL_VERSION="0.1"
: ${COLORS_ENABLED:=0}
: ${CARCH:=$(uname -m)}

print() {
    if [ "$COLORS_ENABLED" = 1 ] && [ -t 1 ] && [ "$TERM" != "dumb" ]
    then
        RESET='\033[0m'
        BOLD='\033[1m'
        RED='\033[91m'
        GREEN='\033[92m'
        YELLOW='\033[93m'
        BLUE='\033[94m'
        MAGENTA='\033[95m'
        CYAN='\033[96m'
        WHITE='\033[97m'
    else
        RESET=''
        BOLD=''
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        MAGENTA=''
        CYAN=''
        WHITE=''
    fi

    if [ "$1" = "MSG" ]
    then
        printf "$GREEN>>>$RESET $BOLD$2:$RESET $3\n"
    elif [ "$1" = "ERR" ]
    then
        printf "$RED>>> ERROR:$RESET $BOLD$2:$RESET $3\n"
    elif [ "$1" = "WARN" ]
    then
        printf "$YELLOW>>>$RESET $BOLD$2:$RESET $3\n"
    else
        printf ">>> $BOLD$2:$RESET $3\n"
    fi
}

log() {
    printf "[$(date +"%H:%M:%S")] $1\n"
}

die(){
    print ERR "$1" "$2"
    exit 1
}

requirevar() {
    for var_name in "$@"
    do
        eval "val=\${$var_name}"
        if [ -z "$val" ]
        then
            print ERR "$var_name" "Undefined variable."
            MISSINGVAR=1
        fi
    done

    if [ "$MISSINGVAR" = "1" ]
    then
        return 1
    fi
}

requirecmd(){
    for cmd_name in "$@"
    do
        if ! command -v "$cmd_name" >/dev/null 2>&1
        then
            print ERR "$cmd_name" "Command not found."
            MISSINGCMD=1
        fi
    done

    if [ "$MISSINGCMD" = "1" ]
    then
        return 1
    fi
}

islinux() {
    if [ "$(uname -s)" = "Linux" ]
    then
        return 0
    else
        return 1
    fi
}

fetch() {
    if command -v curl >/dev/null 2>&1
    then
        curl -f -L -k -C - -o "$2" "$1" >>"$LOGPATH" 2>&1
    elif command -v wget >/dev/null 2>&1
    then
        wget -c -O "$2" "$1" >>"$LOGPATH" 2>&1
    else
        die "Fetch" "unable to find wget or curl."
    fi
}

source() {
    if [ -f "$1" ]
    then
        . "$1"
    else
        die "source" "File does not exist. ($1)"
    fi
}

#!/bin/sh

set -e

export BOOTSTRAP_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export LOGPATH="$BOOTSTRAP_DIR/log.txt"
: ${TOOL_VERSION:=unknown}

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

help() {
    echo "tlbootstrap $TOOL_VERSION"
    echo "Licensed under GPLv3. See the LICENSE file for more information."
    echo ""
    echo "usage: tlbootstrap [argument]"
    echo ""
    echo "  --clean"
    echo "         cleans files and directories"
    echo "  -h, --help"
    echo "         print this help and exit"
    echo "  --log"
    echo "         displays contents of the log file"
    echo "  -s, --start"
    echo "         starts bootstrapping the system"
    echo "  --version"
    echo "         print version information"
}

clean() {
    print MSG "tlbootstrap" "Cleaning..."
    rm -fr "$BOOTSTRAP_DIR/log.txt" "$BOOTSTRAP_DIR/src"/* "$BOOTSTRAP_DIR/$TARGET" "$BOOTSTRAP_DIR/state"/*.done
}

showlog() {
    if [ -f "$LOGPATH" ]
    then
        tail -f "$LOGPATH"
    else
        print WARN "tlbootstrap" "No log file found. Aborting"
    fi
}

flagnotfound() {
    print ERR "tlbootstrap" "unknown option '$1'."
    print WARN "tlbootstrap" "Try 'tlbootstrap --help' for more information."
}

noflag() {
    print ERR "tlbootstrap" "no option mentioned."
    print WARN "tlbootstrap" "Try 'tlbootstrap --help' for more information."
}

runstage() {
    stage="$1"
    statefile=$(printf '%s' "$stage" | tr '/' '_')
    if [ -f "$BOOTSTRAP_DIR/state/${statefile}.done" ]
    then
        print WARN "tlbootstrap" "$stage already done"
        log "$stage already done. Skipping" >>"$LOGPATH"
        return
    fi
    print MSG "tlbootstrap" "Executing $stage"
    log "Executing $stage with '$SHELL'" >>"$LOGPATH"
    BOOTSTRAP_DIR="$BOOTSTRAP_DIR" "$SHELL" "$stage" || { log "Failed in $stage. Aborting" >>"$LOGPATH"; die "tlbootstrap" "Failed in $stage"; }
    touch "$BOOTSTRAP_DIR/state/${statefile}.done"
}

tmpcheck() {
    print MSG "tlbootstrap" "Checking if /tmp is writable..."
    log "Creating '.tlbootstrap-$$.tmp' at /tmp" >>"$LOGPATH"
    touch "/tmp/.tlbootstrap-$$.tmp" >>"$LOGPATH" 2>&1 || {
        log "Not possible to create/write files in /tmp, is tmpfs mounted?" >>"$LOGPATH"
        die "tlbootstrap" "Not possible to create/write files in /tmp, is tmpfs mounted?"
    }
    rm -f "/tmp/.tlbootstrap-$$.tmp"
}

varcheck() {
    print MSG "tlbootstrap" "Checking environment variables..."
    log "Requiring configurating variables..." >>"$LOGPATH"
    requirevar \
        ENDIAN \
        ARCH \
        CPU_FAMILY \
        BINUTILS_URL \
        GCC_URL \
        GMP_URL \
        LINUX_URL \
        MPC_URL \
        MPFR_URL \
        UCLIBC_URL \
        JANSSON_URL \
        TLB_SUDO \
        BUSYBOX_URL \
        ZLIB_URL \
        OPENSSL_URL \
        APKTOOLS_URL \
        FAKEROOT_URL \
	PAXUTILS_URL \
	ABUILD_URL \
	M4_URL \
	GMAKE_URL \
        ZSTD_URL || { 
            log "Variables are missing. [ List sent to stdout ]" >>"$LOGPATH"
            die "tlbootstrap" "Missing configuration. Edit '$BOOTSTRAP_DIR/lib/config.sh'."
        }
}

cmdcheck() {
    print MSG "tlbootstrap" "Checking base commands..."
    log "Requiring commands..." >>"$LOGPATH"
    requirecmd \
        gcc \
        g++ \
        ld \
        rsync \
        tar \
        gzip \
        xz \
        make \
        git \
        bison \
        pkgconf \
        flex \
        curl \
        sed \
        perl \
        aclocal \
        autoreconf \
        libtoolize \
        meson \
	scdoc \
        ninja || { 
            log "Commands are missing. [ List sent to stdout ]" >>"$LOGPATH"
            die "tlbootstrap" "Missing commands."
        }
}

unpoisonenv() {
	unset CC
	unset LD
	unset AS
	unset AR
	unset CXX
	unset CXXFLAGS
	unset CFLAGS
	unset LDFLAGS
	unset CPPFLAGS
}

initialcheck() {
    varcheck
    cmdcheck
    tmpcheck
}

chdir() {
    print MSG "tlbootstrap" "Changing directory ($1)"
    log "Changing directory [ $(pwd) -> $1 ]" >>"$LOGPATH"
    cd "$1"
}

checkstages() {
    print MSG "tlbootstrap" "Checking for stage directories"
    log "Checking for stage directories [ currently defined: $STAGES ]" >>"$LOGPATH"
    for stage in $STAGES
    do
        [ -d "$stage" ] && log "Found $stage at $(realpath $stage)" >>"$LOGPATH" || { log "Stage directory not found [ stage: $stage, defined stages: $STAGES ]" >>"$LOGPATH"; die "$stage" "Stage directory missing."; }
    done
}

setupdirs() {
    print MSG "tlbootstrap" "Creating base directories."
    log "Creating base directories [ src, state ]" >>"$LOGPATH"
    mkdir -p "$BOOTSTRAP_DIR/src" "$BOOTSTRAP_DIR/state" "$BOOTSTRAP_DIR/$TARGET" \
        "$BOOTSTRAP_DIR/$TARGET/usr" "$BOOTSTRAP_DIR/$TARGET/usr/lib" "$BOOTSTRAP_DIR/$TARGET/usr/include" \
        "$BOOTSTRAP_DIR/$TARGET/usr/lib" "$BOOTSTRAP_DIR/$TARGET/usr/bin" \
        "$BOOTSTRAP_DIR/$TARGET/usr/share" "$BOOTSTRAP_DIR/$TARGET/sysroot" \
        "$BOOTSTRAP_DIR/$TARGET/sysroot/usr" "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/include" \
        "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/bin" "$BOOTSTRAP_DIR/$TARGET/sysroot/bin" \
        "$BOOTSTRAP_DIR/$TARGET/sysroot/etc" "$BOOTSTRAP_DIR/$TARGET/sysroot/home" \
        "$BOOTSTRAP_DIR/$TARGET/sysroot/root" "$BOOTSTRAP_DIR/$TARGET/sysroot/var" \
        "$BOOTSTRAP_DIR/$TARGET/sysroot/tmp" "$BOOTSTRAP_DIR/$TARGET/sysroot/proc" \
        "$BOOTSTRAP_DIR/$TARGET/sysroot/sys" "$BOOTSTRAP_DIR/$TARGET/sysroot/dev" \
        "$BOOTSTRAP_DIR/$TARGET/bootstrap" "$BOOTSTRAP_DIR/$TARGET/bootstrap/usr" \
        "$BOOTSTRAP_DIR/$TARGET/bootstrap/usr/bin" "$BOOTSTRAP_DIR/$TARGET/bootstrap/usr/share"
    if [ ! -L "$BOOTSTRAP_DIR/$TARGET/bin" ]
    then
        ln -sf "$BOOTSTRAP_DIR/$TARGET/usr/bin" "$BOOTSTRAP_DIR/$TARGET/bin"
    fi
    if [ ! -L "$BOOTSTRAP_DIR/$TARGET/lib" ]
    then
        ln -sf "$BOOTSTRAP_DIR/$TARGET/usr/lib" "$BOOTSTRAP_DIR/$TARGET/lib"
    fi
}

build() {
    trap 'die "tlbootstrap" "Aborted by user"' INT
    print MSG "tlbootstrap" "Building '$TARGET' (using tlbootstrap $TOOL_VERSION) started $(date +"%a %d %b %Y %H:%M:%S %z")"
    log "Running tlbootstrap $TOOL_VERSION, Interpreter for stage scripts: $SHELL, $(date +"%a %d %b %Y %H:%M:%S %z")" >>"$LOGPATH"
    log "Trying to build '$TARGET'" >>"$LOGPATH"
    initialcheck
    unpoisonenv
    chdir "$BOOTSTRAP_DIR"
    checkstages
    setupdirs
    export PATH="$BOOTSTRAP_DIR/$TARGET/usr/bin:$BOOTSTRAP_DIR/$TARGET/bootstrap/usr/bin:$PATH"
    for s in $STAGES
    do
        for stagefile in "$s"/*
        do
            runstage "$stagefile"
        done
    done
}

case "$1" in
    "--version")
        printf "tlbootstrap $TOOL_VERSION\n"
        exit 0
        ;;
    "-h"|"--help")
        help
        exit 0
        ;;
    ""|" ")
        noflag
        exit 1
        ;;
    "-s"|"--start")
        build
        exit 0
        ;;
    "--log")
        showlog
        exit 0
        ;;
    "--clean")
        clean
        exit 0
        ;;
    *)
        flagnotfound "$1"
        exit 1
        ;;
esac


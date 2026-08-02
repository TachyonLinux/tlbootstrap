#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "uclibc-utils" "Exiting..."' EXIT

print MSG "uclibc-utils" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "uclibc-utils" "Fetching tar archive..."
log "Fetching '$UCLIBC_URL'..." >>"$LOGPATH"
fetch "$UCLIBC_URL" "uclibc.tar.gz"
print MSG "uclibc-utils" "Extracting tar archive..."
log "Extracting 'uclibc.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/uclibc"
tar xfv uclibc.tar.gz -C uclibc --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "uclibc-utils" "Changing directory ($BOOTSTRAP_DIR/src/uclibc)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/uclibc ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/uclibc"
print MSG "uclibc-utils" "Building uclibc-utils..."
log "Building uclibc-utils..." >>"$LOGPATH"
make KERNEL_HEADERS="$BOOTSTRAP_DIR/$TARGET/sysroot/usr/include" CROSS_COMPILE="$TARGET-" utils -j$(nproc) >>"$LOGPATH" 2>&1
make KERNEL_HEADERS="$BOOTSTRAP_DIR/$TARGET/sysroot/usr/include" CROSS_C0MPILE="$TARGET-" DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install_utils -j$(nproc) >>"$LOGPATH" 2>&1

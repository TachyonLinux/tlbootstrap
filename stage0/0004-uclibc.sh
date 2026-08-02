#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "uclibc" "Exiting..."' EXIT

print MSG "uclibc" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "uclibc" "Fetching tar archive..."
log "Fetching '$UCLIBC_URL'..." >>"$LOGPATH"
fetch "$UCLIBC_URL" "uclibc.tar.gz"
print MSG "uclibc" "Extracting tar archive..."
log "Extracting 'uclibc.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/uclibc"
tar xfv uclibc.tar.gz -C uclibc --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "uclibc" "Changing directory ($BOOTSTRAP_DIR/src/uclibc)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/uclibc ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/uclibc"
print MSG "uclibc" "Copying config..."
log "Copying uClibc config for $ARCH..." >>"$LOGPATH"
if [ -f "$BOOTSTRAP_DIR/lib/uclibc-config/config-$ARCH" ]
then
    cp "$BOOTSTRAP_DIR/lib/uclibc-config/config-$ARCH" .config
else
    log "Did not found a config file for uClibc $ARCH." >>"$LOGPATH" 
    die "uclibc" "Config for $ARCH not found"
fi
print MSG "uclibc" "Building uclibc..."
log "Building uclibc" >>"$LOGPATH"
make CROSS_COMPILER_PREFIX="$TARGET-" KERNEL_HEADERS="$BOOTSTRAP_DIR/$TARGET/sysroot/usr/include" -j$(nproc) >>"$LOGPATH" 2>&1
make CROSS_COMPILER_PREFIX="$TARGET-" KERNEL_HEADERS="$BOOTSTRAP_DIR/$TARGET/sysroot/usr/include" DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

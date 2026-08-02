#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "zstd" "Exiting..."' EXIT

print MSG "zstd" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "zstd" "Fetching tar archive..."
log "Fetching '$ZSTD_URL'..." >>"$LOGPATH"
fetch "$ZSTD_URL" "zstd.tar.gz"
print MSG "zstd" "Extracting tar archive..."
log "Extracting 'zstd.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/zstd"
tar xfv zstd.tar.gz -C zstd --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "zstd" "Changing directory ($BOOTSTRAP_DIR/src/zstd)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/zstd ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/zstd"
print MSG "zstd" "Building zstd..."
log "Building zstd" >>"$LOGPATH"
make \
    CC="${TARGET}-gcc" \
    AR="${TARGET}-ar" \
    RANLIB="${TARGET}-ranlib" \
    STRIP="${TARGET}-strip" \
    LD="${TARGET}-ld" \
    PREFIX=/usr \
    lib-mt -j$(nproc) >>"$LOGPATH" 2>&1
make \
    CC="${TARGET}-gcc" \
    AR="${TARGET}-ar" \
    RANLIB="${TARGET}-ranlib" \
    STRIP="${TARGET}-strip" \
    LD="${TARGET}-ld" \
    PREFIX=/usr \
    DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" \
    install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

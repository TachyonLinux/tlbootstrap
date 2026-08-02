#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "zlib" "Exiting..."' EXIT

print MSG "zlib" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "zlib" "Fetching tar archive..."
log "Fetching '$ZLIB_URL'..." >>"$LOGPATH"
fetch "$ZLIB_URL" "zlib.tar.gz"
print MSG "zlib" "Extracting tar archive..."
log "Extracting 'zlib.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/zlib"
tar xfv zlib.tar.gz -C zlib --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "zlib" "Changing directory ($BOOTSTRAP_DIR/src/zlib)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/zlib ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/zlib"
print MSG "zlib" "Building zlib..."
log "Building zlib" >>"$LOGPATH"
CC="$TARGET-gcc" AR="$TARGET-ar" LD="$TARGET-ld" RANLIB="$TARGET-ranlib" GCOV="$TARGET-gcov" "$BOOTSTRAP_DIR/src/zlib/configure" \
    --prefix="/usr" \
    --libdir="/usr/lib" \
    --mandir="/usr/share/man" \
    --static \
    --sharedlibdir="/usr/lib" >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

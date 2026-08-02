#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "gmp" "Exiting..."' EXIT

print MSG "gmp" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "gmp" "Fetching tar archive..."
log "Fetching '$GMP_URL'..." >>"$LOGPATH"
fetch "$GMP_URL" "gmp.tar.gz"
print MSG "gmp" "Extracting tar archive..."
log "Extracting 'gmp.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/gmp"
mkdir -p "$BOOTSTRAP_DIR/src/gmp/build"
tar xfv gmp.tar.gz -C gmp --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "gmp" "Changing directory ($BOOTSTRAP_DIR/src/gmp/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/gmp/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/gmp/build"
print MSG "gmp" "Building gmp..."
log "Building gmp" >>"$LOGPATH"
CFLAGS="-std=gnu17 -fno-lto" "$BOOTSTRAP_DIR/src/gmp/configure" \
    --build="$BUILD" \
    --host="$TARGET" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --includedir=/usr/include \
    --bindir=/usr/bin \
    --mandir=/usr/share/man \
    --disable-shared \
    --enable-static >>"$LOGPATH" 2>&1

make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
rm -f "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/lib"/*.la >>"$LOGPATH" 2>&1
exit 0

#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "mpfr" "Exiting..."' EXIT

print MSG "mpfr" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "mpfr" "Fetching tar archive..."
log "Fetching '$MPFR_URL'..." >>"$LOGPATH"
fetch "$MPFR_URL" "mpfr.tar.gz"
print MSG "mpfr" "Extracting tar archive..."
log "Extracting 'mpfr.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/mpfr"
mkdir -p "$BOOTSTRAP_DIR/src/mpfr/build"
tar xfv mpfr.tar.gz -C mpfr --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "mpfr" "Changing directory ($BOOTSTRAP_DIR/src/mpfr/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/mpfr/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/mpfr/build"
print MSG "mpfr" "Building mpfr..."
log "Building mpfr" >>"$LOGPATH"
CFLAGS="-fno-lto" "$BOOTSTRAP_DIR/src/mpfr/configure" \
    --build="$BUILD" \
    --host="$TARGET" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --includedir=/usr/include \
    --bindir=/usr/bin \
    --mandir=/usr/share/man \
    --disable-shared \
    --with-gmp="$BOOTSTRAP_DIR/$TARGET/sysroot/usr" \
    --enable-static >>"$LOGPATH" 2>&1

make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
rm -f "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/lib"/*.la >>"$LOGPATH" 2>&1
exit 0

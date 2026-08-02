#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "mpc" "Exiting..."' EXIT

print MSG "mpc" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "mpc" "Fetching tar archive..."
log "Fetching '$MPC_URL'..." >>"$LOGPATH"
fetch "$MPC_URL" "mpc.tar.gz"
print MSG "mpc" "Extracting tar archive..."
log "Extracting 'mpc.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/mpc"
mkdir -p "$BOOTSTRAP_DIR/src/mpc/build"
tar xfv mpc.tar.gz -C mpc --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "mpc" "Changing directory ($BOOTSTRAP_DIR/src/mpc/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/mpc/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/mpc/build"
print MSG "mpc" "Building mpc..."
log "Building mpc" >>"$LOGPATH"
CFLAGS="-fno-lto" "$BOOTSTRAP_DIR/src/mpc/configure" \
    --build="$BUILD" \
    --host="$TARGET" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --includedir=/usr/include \
    --bindir=/usr/bin \
    --mandir=/usr/share/man \
    --disable-shared \
    --with-gmp="$BOOTSTRAP_DIR/$TARGET/sysroot/usr" \
    --with-mpfr="$BOOTSTRAP_DIR/$TARGET/sysroot/usr" \
    --enable-static >>"$LOGPATH" 2>&1

make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
rm -f "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/lib"/*.la >>"$LOGPATH" 2>&1
exit 0

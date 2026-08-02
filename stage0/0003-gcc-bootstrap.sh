#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "gcc-bootstrap" "Exiting..."' EXIT

print MSG "gcc-bootstrap" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "gcc-bootstrap" "Fetching tar archive..."
log "Fetching '$GCC_URL'..." >>"$LOGPATH"
fetch "$GCC_URL" "gcc.tar.gz"
print MSG "gcc-bootstrap" "Extracting tar archive..."
log "Extracting 'gcc.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/gcc-bootstrap"
mkdir -p "$BOOTSTRAP_DIR/src/gcc-bootstrap/build"
tar xfv gcc.tar.gz -C gcc-bootstrap --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "gcc-bootstrap" "Changing directory ($BOOTSTRAP_DIR/src/gcc-bootstrap/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/gcc-bootstrap/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/gcc-bootstrap/build"
print MSG "gcc-bootstrap" "Building bootstrap gcc..."
log "Building bootstrap gcc..." >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/gcc-bootstrap/configure" \
    --target="$TARGET" \
    --build="$BUILD" \
    --prefix=/usr \
    --with-sysroot="$BOOTSTRAP_DIR/$TARGET/sysroot" \
    --enable-languages=c \
    --bindir=/usr/bin \
    --mandir=/usr/share/man \
    --includedir=/usr/include \
    --with-newlib \
    --without-headers \
    --disable-shared \
    --disable-threads \
    --disable-libssp \
    --disable-libquadmath \
    --disable-libgomp \
    --disable-libatomic \
    --disable-libsanitizer \
    --disable-libvtv \
    --disable-gprofng \
    --disable-nls \
    --disable-multilib \
    --disable-bootstrap \
    --disable-libstdcxx \
    --disable-werror >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/bootstrap" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

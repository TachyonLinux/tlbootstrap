#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "gcc" "Exiting..."' EXIT

print MSG "gcc" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "gcc" "Fetching tar archive..."
log "Fetching '$GCC_URL'..." >>"$LOGPATH"
fetch "$GCC_URL" "gcc.tar.gz"
print MSG "gcc" "Extracting tar archive..."
log "Extracting 'gcc.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/gcc"
mkdir -p "$BOOTSTRAP_DIR/src/gcc/build"
tar xfv gcc.tar.gz -C gcc --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "gcc" "Changing directory ($BOOTSTRAP_DIR/src/gcc/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/gcc/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/gcc/build"
print MSG "gcc" "Building gcc..."
log "Building full gcc..." >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/gcc/configure" \
    --target="$TARGET" \
    --build="$BUILD" \
    --prefix=/usr \
    --with-sysroot="$BOOTSTRAP_DIR/$TARGET/sysroot" \
    --enable-languages=c,c++ \
    --bindir=/usr/bin \
    --mandir=/usr/share/man \
    --includedir=/usr/include \
    --enable-threads=posix \
    --enable-libstdcxx-threads \
    --disable-multilib \
    --disable-libstdcxx-pch \
    --enable-libstdcxx-time=yes \
    --disable-werror \
    --disable-bootstrap \
    --disable-shared \
    --enable-default-pie \
    --disable-libssp \
    --disable-nls \
    --enable-libgomp \
    --disable-libsanitizer \
    --enable-libquadmath >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET" install -j$(nproc) >>"$LOGPATH" 2>&1
ln -sf "$BOOTSTRAP_DIR/$TARGET/usr/bin/$TARGET-gcc" "$BOOTSTRAP_DIR/$TARGET/usr/bin/$TARGET-cc" >>"$LOGPATH" 2>&1
exit 0

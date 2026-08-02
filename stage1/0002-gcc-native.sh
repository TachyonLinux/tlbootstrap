#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "gcc-native" "Exiting..."' EXIT

print MSG "gcc-native" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "gcc-native" "Fetching tar archive..."
log "Fetching '$GCC_URL'..." >>"$LOGPATH"
fetch "$GCC_URL" "gcc.tar.gz"
print MSG "gcc-native" "Extracting tar archive..."
log "Extracting 'gcc.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/gcc-native"
mkdir -p "$BOOTSTRAP_DIR/src/gcc-native/build"
tar xfv gcc.tar.gz -C gcc-native --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "gcc-native" "Changing directory ($BOOTSTRAP_DIR/src/gcc-native/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/gcc-native/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/gcc-native/build"
print MSG "gcc-native" "Building gcc-native..."
log "Building full gcc-native..." >>"$LOGPATH"
find "$BOOTSTRAP_DIR/src/gcc-native/gcc/config" -name "t-linux64" -exec \
    sed -i.orig -e '/m64=/s/lib64/lib/' -e '/m32=/s/lib32/lib/' {} \;
"$BOOTSTRAP_DIR/src/gcc-native/configure" \
    --host="$TARGET" \
    --target="$TARGET" \
    --build="$BUILD" \
    --prefix=/usr \
    --with-sysroot="/" \
    --with-build-sysroot="$BOOTSTRAP_DIR/$TARGET/sysroot" \
    --enable-languages=c,c++ \
    --with-slibdir=/usr/lib \
    --libdir=/usr/lib \
    --with-toolexeclibdir=/usr/lib \
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
    --enable-default-ssp \
    --disable-libssp \
    --disable-nls \
    --enable-libgomp \
    --disable-libsanitizer \
    --enable-libatomic \
    --enable-libquadmath >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1
find "$BOOTSTRAP_DIR/src/gcc-native/build" -name "Makefile" \
    -exec grep -l "lib64" {} \; | \
    xargs -r sed -i 's#/lib64#/lib#g'
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
ln -sf "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/bin/$TARGET-gcc" "$BOOTSTRAP_DIR/$TARGET/sysroot/usr/bin/$TARGET-cc" >>"$LOGPATH" 2>&1
exit 0

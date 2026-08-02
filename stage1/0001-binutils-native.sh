#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "binutils-native" "Exiting..."' EXIT

print MSG "binutils-native" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "binutils-native" "Fetching tar archive..."
log "Fetching '$BINUTILS_URL'..." >>"$LOGPATH"
fetch "$BINUTILS_URL" "binutils.tar.gz"
print MSG "binutils-native" "Extracting tar archive..."
log "Extracting 'binutils.tar.gz'..." >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/binutils-native"
mkdir -p "$BOOTSTRAP_DIR/src/binutils-native/build"
tar xfv binutils.tar.gz -C binutils-native --strip-components=1 >>"$LOGPATH" 2>&1

print MSG "binutils-native" "Changing directory ($BOOTSTRAP_DIR/src/binutils-native/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/binutils-native/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/binutils-native/build"
print MSG "binutils-native" "Building binutils-native..."
log "Building binutils-native" >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/binutils-native/configure" \
    --host="$TARGET" \
    --target="$TARGET" \
    --build="$BUILD" \
    --with-sysroot="/" \
    --with-build-sysroot="$BOOTSTRAP_DIR/$TARGET/sysroot" \
    --disable-gold \
    --enable-ld=default \
    --disable-shared \
    --disable-werror \
    --disable-nls \
    --prefix=/usr \
    --bindir=/usr/bin \
    --mandir=/usr/share/man \
    --libdir=/usr/lib \
    --libexecdir=/usr/libexec \
    --includedir=/usr/include \
    --disable-gprofng \
    --disable-multilib >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1 
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

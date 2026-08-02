#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "binutils" "Exiting..."' EXIT

print MSG "binutils" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "binutils" "Fetching tar archive..."
log "Fetching '$BINUTILS_URL'..." >>"$LOGPATH"
fetch "$BINUTILS_URL" "binutils.tar.gz"
print MSG "binutils" "Extracting tar archive..."
log "Extracting 'binutils.tar.gz'..." >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/binutils"
mkdir -p "$BOOTSTRAP_DIR/src/binutils/build"
tar xfv binutils.tar.gz -C binutils --strip-components=1 >>"$LOGPATH" 2>&1

print MSG "binutils" "Changing directory ($BOOTSTRAP_DIR/src/binutils/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/binutils/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/binutils/build"
print MSG "binutils" "Building binutils..."
log "Building binutils" >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/binutils/configure" \
    --target="$TARGET" \
    --build="$BUILD" \
    --with-sysroot="$BOOTSTRAP_DIR/$TARGET/sysroot" \
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
make DESTDIR="$BOOTSTRAP_DIR/$TARGET" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

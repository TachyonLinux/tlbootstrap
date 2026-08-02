#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "jansson" "Exiting..."' EXIT

print MSG "jansson" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "jansson" "Fetching tar archive..."
log "Fetching '$JANSSON_URL'..." >>"$LOGPATH"
fetch "$JANSSON_URL" "jansson.tar.gz"
print MSG "jansson" "Extracting tar archive..."
log "Extracting 'jansson.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/jansson"
mkdir -p "$BOOTSTRAP_DIR/src/jansson/build"
tar xfv jansson.tar.gz -C jansson --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "jansson" "Changing directory ($BOOTSTRAP_DIR/src/jansson/build)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/jansson/build ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/jansson/build"
print MSG "jansson" "Building jansson..."
log "Building jansson" >>"$LOGPATH"
CFLAGS="-fno-lto" "$BOOTSTRAP_DIR/src/jansson/configure" \
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

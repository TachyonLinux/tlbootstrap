#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "abuild" "Exiting..."' EXIT

print MSG "abuild" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "abuild" "Fetching tar archive..."
log "Fetching '$ABUILD_URL'..." >>"$LOGPATH"
fetch "$ABUILD_URL" "abuild.tar.gz"
print MSG "abuild" "Extracting tar archive..."
log "Extracting 'abuild.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/abuild"
tar xfv abuild.tar.gz -C abuild --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "abuild" "Changing directory ($BOOTSTRAP_DIR/src/abuild)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/abuild ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/abuild"
print MSG "abuild" "Building abuild..."
log "Building abuild" >>"$LOGPATH"
sed -i "s|pkg-config|${TARGET}-pkg-config|g" Makefile >>"$LOGPATH" 2>&1
make prefix=/usr bindir=/usr/bin CC="$TARGET-gcc" -j$(nproc) >>"$LOGPATH" 2>&1
make prefix=/usr bindir=/usr/bin DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" CC="$TARGET-gcc" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

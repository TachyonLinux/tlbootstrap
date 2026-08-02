#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "fakeroot" "Exiting..."' EXIT

print MSG "fakeroot" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "fakeroot" "Fetching tar archive..."
log "Fetching '$FAKEROOT_URL'..." >>"$LOGPATH"
fetch "$FAKEROOT_URL" "fakeroot.tar.gz"
print MSG "fakeroot" "Extracting tar archive..."
log "Extracting 'fakeroot.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/fakeroot"
tar xfv fakeroot.tar.gz -C fakeroot --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "fakeroot" "Changing directory ($BOOTSTRAP_DIR/src/fakeroot)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/fakeroot ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/fakeroot"
print MSG "fakeroot" "Building fakeroot..."
log "Building fakeroot" >>"$LOGPATH"
log "Downloading newer files for fakeroot" >>"$LOGPATH"
chmod +x bootstrap
"$BOOTSTRAP_DIR/src/fakeroot/bootstrap" >>"$LOGPATH" 2>&1
"$BOOTSTRAP_DIR/src/fakeroot/configure" \
    --build="$BUILD" \
    --host="$TARGET" \
    --prefix=/usr \
    --bindir=/usr/bin \
    --disable-dependency-tracking \
    --libdir=/usr/lib >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

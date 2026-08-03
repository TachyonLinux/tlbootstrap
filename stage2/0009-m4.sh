#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "m4" "Exiting..."' EXIT

print MSG "m4" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "m4" "Fetching tar archive..."
log "Fetching '$M4_URL'..." >>"$LOGPATH"
fetch "$M4_URL" "m4.tar.gz"
print MSG "m4" "Extracting tar archive..."
log "Extracting 'm4.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/m4"
tar xfv m4.tar.gz -C m4 --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "m4" "Changing directory ($BOOTSTRAP_DIR/src/m4)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/m4 ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/m4"
print MSG "m4" "Building m4..."
log "Building m4" >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/m4/configure" \
	--host="$TARGET" \
	--build="$BUILD" \
	--prefix=/usr \
	--bindir=/usr/bin \
	--libdir=/usr/lib \
	--mandir=/usr/share/man \
	--includedir=/usr/include \
	--disable-nls >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1	
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1	
exit 0

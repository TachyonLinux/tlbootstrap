#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "gmake" "Exiting..."' EXIT

print MSG "gmake" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "gmake" "Fetching tar archive..."
log "Fetching '$GMAKE_URL'..." >>"$LOGPATH"
fetch "$GMAKE_URL" "gmake.tar.gz"
print MSG "gmake" "Extracting tar archive..."
log "Extracting 'gmake.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/gmake"
tar xfv gmake.tar.gz -C gmake --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "gmake" "Changing directory ($BOOTSTRAP_DIR/src/gmake)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/gmake ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/gmake"
print MSG "gmake" "Building gmake..."
log "Building gmake" >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/gmake/configure" \
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

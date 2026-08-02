#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "openssl" "Exiting..."' EXIT

print MSG "openssl" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "openssl" "Fetching tar archive..."
log "Fetching '$OPENSSL_URL'..." >>"$LOGPATH"
fetch "$OPENSSL_URL" "openssl.tar.gz"
print MSG "openssl" "Extracting tar archive..."
log "Extracting 'openssl.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/openssl"
tar xfv openssl.tar.gz -C openssl --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "openssl" "Changing directory ($BOOTSTRAP_DIR/src/openssl)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/openssl ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/openssl"
print MSG "openssl" "Building openssl..."
log "Building openssl" >>"$LOGPATH"
"$BOOTSTRAP_DIR/src/openssl/Configure" \
    --cross-compile-prefix="$TARGET-" \
    --prefix=/usr \
    --openssldir="/etc/ssl" \
    --libdir="lib" \
    threads \
    no-shared >>"$LOGPATH" 2>&1
make -j$(nproc) >>"$LOGPATH" 2>&1
make DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "linux" "Exiting..."' EXIT

print MSG "linux" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "linux" "Fetching tar archive..."
log "Fetching '$LINUX_URL'..." >>"$LOGPATH"
fetch "$LINUX_URL" "linux.tar.gz"
print MSG "linux" "Extracting tar archive..."
log "Extracting 'linux.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/linux"
tar xfv linux.tar.gz -C linux --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "linux" "Changing directory ($BOOTSTRAP_DIR/src/linux)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/linux ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/linux"
print MSG "linux" "Installing headers..."
log "Installing linux headers [ $BOOTSTRAP_DIR/$TARGET/sysroot/usr/include ]" >>"$LOGPATH"
make headers_install ARCH="$ARCH" INSTALL_HDR_PATH="$BOOTSTRAP_DIR/$TARGET/sysroot/usr" -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

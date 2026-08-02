#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "busybox" "Exiting..."' EXIT

print MSG "busybox" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "busybox" "Fetching tar archive..."
log "Fetching '$BUSYBOX_URL'..." >>"$LOGPATH"
fetch "$BUSYBOX_URL" "busybox.tar.gz"
print MSG "busybox" "Extracting tar archive..."
log "Extracting 'busybox.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/busybox"
tar xfv busybox.tar.gz -C busybox --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "busybox" "Changing directory ($BOOTSTRAP_DIR/src/busybox)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/busybox ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/busybox"
print MSG "busybox" "Building busybox..."
log "Building busybox" >>"$LOGPATH"
make ARCH="$ARCH" defconfig -j$(nproc) >>"$LOGPATH" 2>&1
sed -i "s|^CONFIG_CROSS_COMPILER_PREFIX=.*|CONFIG_CROSS_COMPILER_PREFIX=\"${TARGET}-\"|" .config
sed -i "s|^CONFIG_TC=.*|CONFIG_TC=n|" .config
sed -i "s|^CONFIG_INSTALL_APPLET_SYMLINKS=.*|CONFIG_INSTALL_APPLET_SYMLINKS=y|" .config
sed -i "s|^CONFIG_PREFIX=.*|CONFIG_PREFIX=\"$BOOTSTRAP_DIR/$TARGET/sysroot\"|" .config
make -j$(nproc) V=1 >>"$LOGPATH" 2>&1
yes "" | make install -j$(nproc) >>"$LOGPATH" 2>&1
exit 0

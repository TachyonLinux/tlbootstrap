#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "apk-tools" "Exiting..."' EXIT

print MSG "apk-tools" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "apk-tools" "Fetching tar archive..."
log "Fetching '$APKTOOLS_URL'..." >>"$LOGPATH"
fetch "$APKTOOLS_URL" "apk-tools.tar.gz"
print MSG "apk-tools" "Extracting tar archive..."
log "Extracting 'apk-tools.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/apk-tools"
tar xfv apk-tools.tar.gz -C apk-tools --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "apk-tools" "Changing directory ($BOOTSTRAP_DIR/src/apk-tools)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/apk-tools ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/apk-tools"
print MSG "apk-tools" "Building apk-tools..."
log "Building apk-tools" >>"$LOGPATH"
cat > "$BOOTSTRAP_DIR/src/apk-tools/cross-uclibc.ini" << EOF
[binaries]
c = '${TARGET}-gcc'
cpp = '${TARGET}-g++'
ar = '${TARGET}-ar'
strip = '${TARGET}-strip'
pkg-config = '${TARGET}-pkg-config'

[host_machine]
system = 'linux'
cpu_family = '${CPU_FAMILY}'
cpu = '${ARCH}'
endian = '${ENDIAN}'

[properties]
sys_root = '${BOOTSTRAP_DIR}/${TARGET}/sysroot'
EOF
meson setup build \
    --cross-file cross-uclibc.ini \
    --prefix=/usr \
    --libdir=lib \
    --default-library=static \
    -Dhelp=disabled \
    -Dlua=disabled \
    -Durl_backend=libfetch >>"$LOGPATH" 2>&1
ninja -C build >>"$LOGPATH" 2>&1
DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" ninja -C build install >>"$LOGPATH" 2>&1

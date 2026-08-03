#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "pax-utils" "Exiting..."' EXIT

print MSG "pax-utils" "Changing directory ($BOOTSTRAP_DIR/src)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src ]" >>"$LOGPATH"

cd "$BOOTSTRAP_DIR/src"
print MSG "pax-utils" "Fetching tar archive..."
log "Fetching '$PAXUTILS_URL'..." >>"$LOGPATH"
fetch "$PAXUTILS_URL" "pax-utils.tar.gz"
print MSG "pax-utils" "Extracting tar archive..."
log "Extracting 'pax-utils.tar.gz'" >>"$LOGPATH"
mkdir -p "$BOOTSTRAP_DIR/src/pax-utils"
tar xfv pax-utils.tar.gz -C pax-utils --strip-components=1 >>"$LOGPATH" 2>&1
print MSG "pax-utils" "Changing directory ($BOOTSTRAP_DIR/src/pax-utils)."
log "Changing directory [ $(pwd) -> $BOOTSTRAP_DIR/src/pax-utils ]" >>"$LOGPATH"
cd "$BOOTSTRAP_DIR/src/pax-utils"
print MSG "pax-utils" "Building pax-utils..."
log "Building pax-utils" >>"$LOGPATH"
cat > "$BOOTSTRAP_DIR/src/pax-utils/cross-uclibc.ini" << EOF
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
	-Duse_libcap=disabled \
	-Duse_seccomp=false >>"$LOGPATH" 2>&1
ninja -C build >>"$LOGPATH" 2>&1
DESTDIR="$BOOTSTRAP_DIR/$TARGET/sysroot" ninja -C build install >>"$LOGPATH" 2>&1
exit 0

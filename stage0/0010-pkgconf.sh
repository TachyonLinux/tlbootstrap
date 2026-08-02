#!/bin/sh

set -e

. "$BOOTSTRAP_DIR/lib/config.sh"
. "$BOOTSTRAP_DIR/lib/common.sh"

trap 'print MSG "pkgconf" "Exiting..."' EXIT

print MSG "pkgconf" "Creating pkgconf wrapper..."
log "Creating pkgconf wrapper" >>"$LOGPATH"
cat > "$BOOTSTRAP_DIR/$TARGET/usr/bin/$TARGET-pkg-config" << EOF
#!/bin/sh
export PKG_CONFIG_SYSROOT_DIR="\$BOOTSTRAP_DIR/\$TARGET/sysroot"
export PKG_CONFIG_LIBDIR="\$BOOTSTRAP_DIR/\$TARGET/sysroot/usr/lib/pkgconfig:\$BOOTSTRAP_DIR/\$TARGET/sysroot/usr/share/pkgconfig"
unset PKG_CONFIG_PATH
exec pkgconf "\$@"
EOF
chmod +x "$BOOTSTRAP_DIR/$TARGET/usr/bin/$TARGET-pkg-config"
exit 0

#!/bin/sh



# tlbootstrap config

export ENABLE_VERBOSE=0
export COLORS_ENABLED=1
export ARCH="x86_64"
export CPU_FAMILY="$ARCH"
export VENDOR="tachyon"
export TARGET="$ARCH-$VENDOR-linux-uclibc"
export SHELL="/bin/sh"
export BUILD="$(gcc -dumpmachine)"
export STAGES="stage0 stage1 stage2 stage3"
export TLB_SUDO="sudo"
export ENDIAN="little"

# source code

export GMP_URL="http://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.gz"
export MPFR_URL="http://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.gz"
export MPC_URL="http://ftp.gnu.org/gnu/mpc/mpc-1.4.1.tar.xz"
export BINUTILS_URL="http://ftp.gnu.org/gnu/binutils/binutils-2.46.0.tar.gz"
export GCC_URL="http://ftp.gnu.org/gnu/gcc/gcc-16.1.0/gcc-16.1.0.tar.gz"
export LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.1.3.tar.gz"
export UCLIBC_URL="https://downloads.uclibc-ng.org/releases/1.0.58/uClibc-ng-1.0.58.tar.gz"
export JANSSON_URL="https://github.com/akheron/jansson/releases/download/v2.15.1/jansson-2.15.1.tar.gz"
export BUSYBOX_URL="http://busybox.net/downloads/busybox-1.38.0.tar.bz2"
export ZLIB_URL="https://zlib.net/zlib-1.3.2.tar.gz"
export OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-4.0.1/openssl-4.0.1.tar.gz"
export APKTOOLS_URL="https://gitlab.alpinelinux.org/alpine/apk-tools/-/archive/v3.0.6/apk-tools-v3.0.6.tar.gz"
export ZSTD_URL="https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz"
export FAKEROOT_URL="https://github.com/TachyonLinux/fakeroot/archive/refs/tags/v0.1.tar.gz"
export PAXUTILS_URL="https://github.com/gentoo/pax-utils/archive/refs/tags/v1.3.11.tar.gz"

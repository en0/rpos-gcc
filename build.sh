#!/usr/bin/env bash

export SYSROOT="$(readlink -f $(pwd)/../../..)"
export PREFIX="${SYSROOT}/usr"
export TARGET=i686-rpos
export PATH="${PREFIX}/bin:$PATH"

rm -rf gcc-build
mkdir gcc-build
cd gcc-build

../configure --target=$TARGET --prefix=$PREFIX --with-sysroot=${SYSROOT} --disable-nls --enable-languages=c
#../configure --target=$TARGET --prefix=$PREFIX --with-sysroot=${SYSROOT} --with-newlib --with-gnu-as --with-gnu-ld --disable-shared --disable-libssp --enable-languages=c
[ $? == 0 ] && make all
[ $? == 0 ] && make install
[ $? != 0 ] && exit 2

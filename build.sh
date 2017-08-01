#!/usr/bin/env bash

#export SYSROOT="$(readlink -f $(pwd)/../../..)"
#export PREFIX="${SYSROOT}/usr"
#export TARGET=i686-rpos
#export PATH="${PREFIX}/bin:$PATH"

#../configure --target=$TARGET --prefix=$PREFIX --with-sysroot=${SYSROOT} --disable-nls --enable-languages=c
#../configure --target=$TARGET --prefix=$PREFIX --with-sysroot=${SYSROOT} --with-newlib --disable-shared --disable-libssp --enable-languages=c

abort() {
    MESSAGE=$1
    EXITCODE=$2
    if [[ -z "$EXITCODE" ]]
    then
        EXITCODE=1
    fi

    printf "ERROR: %s\n" "${MESSAGE}" 1>&2
    exit $EXITCODE
}

require_env() {
    [[ -z "$2" ]] && \
        abort "\$$1 is not set. Please source the desired environment." 1
}

require_env "SYSROOT" "${SYSROOT}"
require_env "PREFIX" "${PREFIX}"
require_env "TARGET" "${TARGET}"
require_env "PATH" "${PATH}"

rm -rf gcc-build
mkdir gcc-build
cd gcc-build

CONFIG="--target=${TARGET} --prefix=${PREFIX}"

## Enabled languages
CONFIG="${CONFIG} --enable-languages=c"

## Disabled Features
CONFIG="${CONFIG} --disable-shared --disable-libssp"

case ${TARGET} in

i[34567]86-elf*)

    # Building generic elf target will have no libc but will have libgcc
    # for basic math and data types such as size_t and uint32_t.

    ../configure \
        ${CONFIG} \
        --disable-nls \
        --without-headers &&
    make all-gcc &&
    make all-target-libgcc &&
    make install-gcc &&
    make install-target-libgcc ;;

i[34567]86-rpos*)

    # Building os specific target depends on newlib. Newlib must be built
    # first. This will produce a cross comipler that builds binaries
    # specific to RPOS.

    ../configure \
        ${CONFIG} \
        --with-sysroot=${SYSROOT} \
        --with-newlib &&
    make all &&
    make install ;;

esac

exit

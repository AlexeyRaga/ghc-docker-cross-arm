#!/bin/bash

_toolchain=${TOOLCHAIN:-/opt/toolchain}

mkdir -p ${_toolchain}
wget http://releases.linaro.org/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz

tar xf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz -C ${_toolchain}
rm *.tar.xz

rm -rf ${_toolchain}/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/share/doc
rm -rf ${_toolchain}/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/share/locale

ln -s ${_toolchain}/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux ${_toolchain}/gcc-linaro-arm-linux-gnueabihf

for i in `ls ${_toolchain}/gcc-linaro-arm-linux-gnueabihf/bin/*`; do
    ln -s $i /usr/bin/$(basename $i)
done

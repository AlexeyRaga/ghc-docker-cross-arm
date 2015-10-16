#!/bin/bash

_ghc_ver=${GHC_VER:-7.10.2}
_ghc_target="/opt/ghc-cross-${_ghc_ver}"

wget http://downloads.haskell.org/~ghc/${_ghc_ver}/ghc-${_ghc_ver}-src.tar.bz2
tar xf ghc-${_ghc_ver}-src.tar.bz2
rm *.tar.bz2
cd ghc-${_ghc_ver}
sed -i 's/^PACKAGES_STAGE1 += terminfo$/\#\0/g' ghc.mk
sed -i 's/^PACKAGES_STAGE1 += haskeline$/\#\0/g' ghc.mk
cp mk/build.mk.sample mk/build.mk
sed -i 's/^#\(BuildFlavour *= *quick-cross\)$/\1/g' mk/build.mk
sed -i 's/^SRC_HC_OPTS *= .*$/SRC_HC_OPTS = -O -H64m/g' mk/build.mk
sed -i 's/^GhcStage1HcOpts *= .*$/GhcStage1HcOpts = -O -fasm/g' mk/build.mk
sed -i 's/^GhcStage2HcOpts *= .*$/GhcStage2HcOpts = -O2 -fasm/g' mk/build.mk
sed -i 's/^GhcLibHcOpts *= .*$/GhcLibHcOpts = -O2/g' mk/build.mk
./configure --target=arm-linux-gnueabihf --with-gcc=arm-linux-gnueabihf-gcc --prefix=${_ghc_target}
make && sudo make install
cd .. && rm -rf ghc-${_ghc_ver}
rm ${_ghc_target}/bin/ghci* ${_ghc_target}/bin/run*

for i in `ls ${_ghc_target}/bin/*-${_ghc_ver}`; do
   ln -s $i "`echo $i | sed 's|\(.*\)-${_ghc_ver}|\1|'`"
   ln -s $i "`echo $i | sed 's|(-unknown)?||'`"
done

find ${_ghc_target}/bin -type l -exec cp {} /usr/bin/ \;
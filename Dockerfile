# mount the GHC source code into /home/ghc
#
#    docker run --rm -it --privileged -v `pwd`:/home/ghc alexeyraga/ghc-cross-arm /bin/bash
#

FROM quay.io/alexeyraga/ghc-7.8.4
MAINTAINER Alexey Raga

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

## custom apt-get install options
ENV OPTS_APT        -y --force-yes --no-install-recommends

RUN sudo apt-get update \
 && sudo apt-get install ${OPTS_APT} \
    libc6-i386 lib32stdc++6 zlib1g lib32gcc1 lib32z1 lib32ncurses5

RUN \
    sudo mkdir -p /opt/toolchain \
    && wget http://releases.linaro.org/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz \
    && sudo tar xJf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz -C /opt/toolchain \
    && rm *.tar.xz

RUN sudo ln -s /opt/toolchain/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux /opt/toolchain/gcc-linaro-arm-linux-gnueabihf

RUN sudo ln -s /opt/toolchain/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc /usr/bin/arm-linux-gnueabihf-gcc

RUN \
    export PATH=/opt/toolchain/gcc-linaro-arm-linux-gnueabihf/bin:$PATH \
    && wget http://downloads.haskell.org/~ghc/7.10.2/ghc-7.10.2-src.tar.bz2 \
    && sudo tar xf ghc-7.10.2-src.tar.bz2 \
    && rm *.tar.bz2 \
    && cd ghc-7.10.2 \
    && sed -i 's/^PACKAGES_STAGE1 += terminfo$/\#\0/g' ghc.mk \
    && sed -i 's/^PACKAGES_STAGE1 += haskeline$/\#\0/g' ghc.mk \
    && cp mk/build.mk.sample mk/build.mk \
    && sed -i 's/^#\(BuildFlavour *= *quick-cross\)$/\1/g' mk/build.mk \
    && sed -i 's/^SRC_HC_OPTS *= .*$/SRC_HC_OPTS = -O -H64m/g' mk/build.mk \
    && sed -i 's/^GhcStage1HcOpts *= .*$/GhcStage1HcOpts = -O -fasm/g' mk/build.mk \
    && sed -i 's/^GhcStage2HcOpts *= .*$/GhcStage2HcOpts = -O2 -fasm/g' mk/build.mk \
    && sed -i 's/^GhcLibHcOpts *= .*$/GhcLibHcOpts = -O2/g' mk/build.mk \
    && ./configure --target=arm-linux-gnueabihf --with-gcc=arm-linux-gnueabihf-gcc --prefix=/opt/ghc-cross-7.10.2 \
    && make && sudo make install \
    && cd .. && rm -rf ghc-7.10.2 \
    && sudo rm /opt/ghc-cross-7.10.2/bin/ghci* /opt/ghc-cross-7.10.2/bin/run*

RUN sudo ln -s /opt/ghc-cross-7.10.2/bin/arm-unknown-linux-gnueabihf-runghc-7.10.2 /opt/ghc-cross-7.10.2/bin/arm-unknown-linux-gnueabihf-runghc

RUN sudo ln -s /opt/ghc-cross-7.10.2/bin/arm-unknown-linux-gnueabihf-runghc /opt/ghc-cross-7.10.2/bin/arm-unknown-linux-gnueabihf-runhaskell

RUN sudo ln -s /usr/bin/cabal-1.22 /usr/local/bin/cabal
RUN sudo ln -s /opt/ghc-cross-7.10.2/bin/arm-unknown-linux-gnueabihf-ghc-7.10.2 /usr/local/bin/arm-linux-ghc-7.10.2

ADD ./cabal-arm /opt/cabal-arm
RUN sudo chmod +x /opt/cabal-arm && sudo ln -s /opt/cabal-arm /usr/local/bin/cabal-arm

ENV PATH /opt/ghc-cross-7.10.2/bin:/opt/toolchain/gcc-linaro-arm-linux-gnueabihf/bin:$PATH 
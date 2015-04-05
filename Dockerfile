# mount the GHC source code into /home/ghc
#
#    sudo docker run --rm -i -t -v `pwd`:/home/ghc alexeyraga/ghc-cross-arm /bin/bash
#

FROM alexeyraga/ghc-dev:latest
MAINTAINER Alexey Raga

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

## custom apt-get install options
ENV OPTS_APT        -y --force-yes --no-install-recommends

RUN sudo apt-get update \
 && sudo apt-get install ${OPTS_APT} \
    libc6-i386 lib32stdc++6 zlib1g lib32gcc1 lib32z1 
    #\ lib32ncurses5

RUN \
    sudo mkdir -p /opt/toolchain \
    && wget http://dn.odroid.com/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz \
    && sudo tar xJf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz -C /opt/toolchain \
    && rm *.tar.xz \
    && sudo ln -s /opt/toolchain/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux /opt/toolchain/gcc-linaro-arm-linux-gnueabihf

# RUN \
#     export PATH=/opt/toolchain/gcc-linaro-arm-linux-gnueabihf/bin:$PATH \
#     && sudo mkdir -p /opt/toolchain/ncurses \
#     && wget http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz \
#     && sudo tar zxf ncurses-5.9.tar.gz -C /opt/toolchain/ncurses/ \
#     && rm *.tar.gz \
#     && cd /opt/toolchain/ncurses/ncurses-5.9 \
#     && sudo ./configure --target=arm-linux-gnueabihf --with-gcc=arm-linux-gnueabihf-gcc --with-shared --host=arm-linux-gnueabihf --with-build-cpp=arm-linux-gnueabihf-g++ --prefix=/opt/arm \
#     && sudo make && sudo make install

RUN \
    export PATH=/opt/toolchain/gcc-linaro-arm-linux-gnueabihf/bin:$PATH \
    && wget https://www.haskell.org/ghc/dist/7.8.4/ghc-7.8.4-src.tar.bz2 \
    && sudo tar xf ghc-7.8.4-src.tar.bz2 \
    && rm *.tar.bz2 \
    && cd ghc-7.8.4 \
    && sed -i 's/^PACKAGES_STAGE1 += terminfo$/\#\0/g' ghc.mk \
    && sed -i 's/^PACKAGES_STAGE1 += haskeline$/\#\0/g' ghc.mk \
    && cp mk/build.mk.sample mk/build.mk \
    && sed -i 's/^#\(BuildFlavour *= *quick-cross\)$/\1/g' mk/build.mk \
    && sed -i 's/^SRC_HC_OPTS *= .*$/SRC_HC_OPTS = -O -H64m/g' mk/build.mk \
    && sed -i 's/^GhcStage1HcOpts *= .*$/GhcStage1HcOpts = -O -fasm/g' mk/build.mk \
    && sed -i 's/^GhcStage2HcOpts *= .*$/GhcStage2HcOpts = -O2 -fasm/g' mk/build.mk \
    && sed -i 's/^GhcLibHcOpts *= .*$/GhcLibHcOpts = -O2/g' mk/build.mk \
    && ./configure --target=arm-linux-gnueabihf --with-gcc=arm-linux-gnueabihf-gcc --prefix=/opt/ghc-cross-7.8.4 \
    && make && sudo make install \
    && cd .. && rm -rf ghc-7.8.4 \
    && sudo rm /opt/ghc-cross-7.8.4/bin/ghci* /opt/ghc-cross-7.8.4/bin/run* \

RUN sudo ln -s /opt/ghc-cross-7.8.4/bin/arm-unknown-linux-gnueabihf-runghc-7.8.4 /opt/ghc-cross-7.8.4/bin/arm-unknown-linux-gnueabihf-runghc
RUN sudo ln -s /opt/ghc-cross-7.8.4/bin/arm-unknown-linux-gnueabihf-runghc-7.8.4 /opt/ghc-cross-7.8.4/bin/arm-unknown-linux-gnueabihf-runghc

RUN sudo ln -s /usr/bin/cabal-1.22 /usr/bin/cabal
RUN sudo ln -s /opt/ghc-cross-7.8.4/bin/arm-unknown-linux-gnueabihf-ghc-7.8.4 /usr/local/bin/arm-linux-ghc-7.8.4
RUN sudo ln -s /opt/ghc-cross-7.8.4/lib/arm-unknown-linux-gnueabihf-ghc-7.8.4 /usr/local/lib/arm-linux-ghc-7.8.4

ADD ./cabal-arm /opt/cabal-arm
RUN sudo chmod +x /opt/cabal-arm && sudo ln -s /opt/cabal-arm /usr/local/bin/cabal-arm

ENV PATH /opt/ghc-cross-7.8.4/bin:/opt/toolchain/gcc-linaro-arm-linux-gnueabihf/bin:$PATH 
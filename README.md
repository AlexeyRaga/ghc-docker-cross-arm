# A docker container for hacking on GHC

This is on the docker registry as `ghc-docker-dev`.
To use, mount your GHC source code into /home/ghc

    sudo docker run --rm -i -t -v `pwd`:/home/ghc alexeyraga/ghc-cross-arm /bin/bash

You are now ready to compile GHC!

To cross-compile use ```cabal-arm``` command


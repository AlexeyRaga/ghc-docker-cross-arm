[![Docker Repository on Quay.io](https://quay.io/repository/alexeyraga/ghc-arm-7.10.2/status "Docker Repository on Quay.io")](https://quay.io/repository/alexeyraga/ghc-arm-7.10.2)

# A docker container for hacking on GHC

This is on the docker registry as `quay.io/alexeyraga/ghc-arm-7.10.2`.
To use, mount your GHC source code into /home/ghc

    docker run --rm -i -t -v `pwd`:/home/ghc quay.io/alexeyraga/ghc-arm-7.10.2 /bin/bash

You are now ready to compile GHC!

To cross-compile use ```cabal-arm``` command

### Issues

I've found that `cabal-arm init` creates a project that has a dependency on `base < 4.8` while the "current" base was actually `4.8` so I have to fix it manually in a `*.cabal` file.


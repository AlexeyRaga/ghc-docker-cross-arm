#!/bin/bash

apt-get update 
apt-get install -y --force-yes --no-install-recommends \
    libc6-i386 lib32stdc++6 zlib1g lib32gcc1 lib32z1 lib32ncurses5

 apt-get clean
 
 /usr/local/bin/clean.sh
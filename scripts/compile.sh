#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

function downloadUncached {
    if [ -f "$2" ]
    then
        sha=$(sha256sum "$2" | cut -d ' ' -f 1)
        if [ "$sha" = "$3" ]
        then
            echo "RET"
            return
        fi
    fi
    wget -v "$1" -O "$2"
}

function buildMesa {
    file=mesa-21.0.0-rc5.tar.xz
    downloadUncached https://archive.mesa3d.org/$file "/tmp/$file" f57d23aa69d5ed7cfde250a7bf8f72285a34692f9e8d541532fa6970f941ce01
    tar -xJf "/tmp/$file"
    mkdir -p builddir
    pip3 install meson
    PATH=/home/pi/.local/bin:$PATH
    meson builddir/
    #ninja -C builddir/
    #sudo ninja -C builddir/ install
}

buildMesa

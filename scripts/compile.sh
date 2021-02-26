#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

BASENAME=$(basename "$0")
CANONICAL_SCRIPT=$(readlink -e "$0")
SCRIPT_DIR=$(dirname "${CANONICAL_SCRIPT}")
ROOT_DIR=$(dirname "${SCRIPT_DIR}")

function downloadUncached {
    if [ -f "$2" ]
    then
        sha=$(sha256sum "$2" | cut -d ' ' -f 1)
        if [ "$sha" = "$3" ]
        then
            return
        fi
    fi
    wget -v "$1" -O "$2"
}

function buildMesa {
    (
        cd "$HOME/.cache"
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-bin_1.18.0-2~exp1.1_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-cursor0_1.18.0-2~exp1.1_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-dev_1.18.0-2~exp1.1_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-egl1_1.18.0-2~exp1.1_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-egl-backend-dev_1.18.0-2~exp1.1_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-server0_1.18.0-2~exp1.1_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/libf/libffi/libffi-dev_3.3-5_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/libf/libffi/libffi7_3.3-5_arm64.deb
        curl -O http://ftp.de.debian.org/debian/pool/main/w/wayland/libwayland-client0_1.18.0-2~exp1.1_arm64.deb
        sudo dpkg -i "$HOME/.cache/libffi"*.deb "$HOME/.cache/libwayland"*.deb
    )
    sudo apt-get install bison\
                         flex\
                         libdrm-dev\
                         libwayland-client0\
                         libwayland-dev\
                         wayland-protocols\
                         libx11-dev\
                         libxext-dev\
                         libxfixes-dev\
                         libxcb-glx0-dev\
                         libxcb-shm0-dev\
                         libx11-xcb-dev\
                         libxcb-dri2-0-dev\
                         libxcb-dri3-dev\
                         libxcb-present-dev\
                         libxshmfence-dev\
                         libxxf86vm-dev\
                         libxrandr-dev\
                         ninja-build  -y
    pip3 install meson mako
    sudo pip3 install meson mako
    file=mesa-21.0.0-rc5.tar.xz
    downloaded="$HOME/.cache/$file"
    downloadUncached https://archive.mesa3d.org/$file "$downloaded" f57d23aa69d5ed7cfde250a7bf8f72285a34692f9e8d541532fa6970f941ce01
    rm -rf "$HOME/.cache/mesa_source" || true
    mkdir -p "$HOME/.cache/mesa_source"
    tar -xJf "$downloaded" -C "$HOME/.cache/mesa_source" --strip-components=1
    PATH=/home/pi/.local/bin:$PATH
    (
        cd "$HOME/.cache/mesa_source"
        builddir="$HOME/.cache/mesa_build"
        mkdir -p "$builddir"
        cp "${ROOT_DIR}/mesa_options.txt" "$HOME/.cache/mesa_source/meson_options.txt"
        meson "$HOME/.cache/mesa_build" -Dplatforms=x11,wayland -Ddri-drivers='' -Dgallium-drivers=v3d,vc4 -Dvulkan-drivers=broadcom
        ninja -C "$builddir/"
        sudo ninja -C "$builddir/" install
    )
}

buildMesa

# syntax=docker/dockerfile:1

# builder build the modded library using alpine (musl libc)
# note the we use a fixed version for both the builder and the resulting image
# like that we are sure to not fall in dependecy version hell

# Commands are taken from qbittorrent wiki pages
FROM alpine:edge as builder
RUN \
apk --no-cache add --virtual qdev autoconf automake build-base cmake curl git libtool linux-headers perl pkgconf python3 python3-dev re2c tar && \
apk --no-cache add --virtual runtime icu-dev openssl-dev qt5-qtbase-dev qt5-qttools-dev zlib-dev qt5-qtsvg-dev && \
git clone --shallow-submodules --recurse-submodules https://github.com/ninja-build/ninja.git ~/ninja && cd ~/ninja && \
git checkout "$(git tag -l --sort=-v:refname "v*" | head -n 1)" && \
cmake -Wno-dev -B build \
    -D CMAKE_BUILD_TYPE="MinSizeRel" \
    -D CMAKE_CXX_STANDARD=20 \
    -D CMAKE_INSTALL_PREFIX="/usr/local" && \
cmake --build build && \
cmake --install build && \
curl -sNLk https://boostorg.jfrog.io/artifactory/main/release/1.85.0/source/boost_1_85_0.tar.gz -o "$HOME/boost_1_85_0.tar.gz" && \
tar xf "$HOME/boost_1_85_0.tar.gz" -C "$HOME" && \
git clone -b mult --shallow-submodules --recurse-submodules https://github.com/maxisoft/libtorrent.git ~/libtorrent && cd ~/libtorrent && \
cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_CXX_STANDARD=20 \
    -D BOOST_INCLUDEDIR="$HOME/boost_1_85_0/" \
    -D CMAKE_INSTALL_LIBDIR="lib" \
    -D CMAKE_INSTALL_PREFIX="/usr/local" && \
cmake --build build && \
cmake --install build && \
mkdir -p /output/lib && \
cp -a /usr/local/lib/libtorrent*.so* /output/lib/ && \
apk del --purge qdev && apk del --purge runtime && \
cd "$HOME" && rm -rf libtorrent ninja boost_1_85_0 boost_1_85_0.tar.gz

# use qbittorrent docker image from linuxserver as base
# the resulting image will multiply uploaded bytes by a factor of 2 (by default)
FROM ghcr.io/linuxserver/qbittorrent:4.6.5
ARG LIB_TORRENT_UPLOAD_MULT=2.0
ARG maintainer="maxisoft"
LABEL maintainer="${maintainer}" name="qbittorrent-docker-ratio-faker" description="Qbittorent with built in fake ratio multiplier" url="https://github.com/${maintainer}/qbittorrent-docker-ratio-faker" vcs-url="https://github.com/${maintainer}/qbittorrent-docker-ratio-faker" org.opencontainers.image.source="https://github.com/${maintainer}/qbittorrent-docker-ratio-faker"
COPY --from=builder /output/lib/* /usr/local/lib/
ENV LIB_TORRENT_UPLOAD_MULT=${LIB_TORRENT_UPLOAD_MULT}

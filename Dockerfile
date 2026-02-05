FROM debian:trixie-slim AS base

RUN apt-get update && apt-get install -y \
    git \
    autoconf \
    libtool \
    automake \
    build-essential \
    gettext \
    cmake \
    python3 \
    curl

RUN git clone https://gitlab.winehq.org/mono/mono.git \
  && cd mono \
  && sh autogen.sh --prefix=/usr/local \
  && make \
  && make install


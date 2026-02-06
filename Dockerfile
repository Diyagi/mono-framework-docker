FROM debian:trixie-slim AS build

RUN apt-get update && apt-get install -y \
    ccache \
    git \
    build-essential \
    ca-certificates \
    autoconf \
    libtool \
    automake \
    cmake \
    python3 \
    gettext \
    wget \
    pkg-config \
    libglib2.0-dev \
    libcairo2-dev \
    libjpeg62-turbo-dev \
    libtiff-dev \
    libgif-dev \
    libexif-dev \
    moreutils \
    binutils \
    mono-complete

RUN git clone https://gitlab.winehq.org/mono/mono.git

ENV BASEDIR="/mono"
ENV PATH="/usr/lib/ccache:$PATH"
ENV BUILD_DIR="/mono-build"

WORKDIR $BASEDIR
RUN sh scripts/ci/update-submodules.sh
RUN sh autogen.sh \
  --prefix=$BUILD_DIR \
  --disable-static \
  --enable-shared \
  --with-mcs-docs=no \
  --enable-minimal=profiler,debug
  
RUN make -j$(nproc)
RUN make -j$(nproc) install

RUN find $BUILD_DIR -type f -exec strip --strip-unneeded {} + 2>/dev/null || true
RUN find $BUILD_DIR -type f -name '*.pdb' -delete
RUN rm -rf $BUILD_DIR/lib/pkgconfig \
  $BUILD_DIR/lib/mono-source-libs \
  $BUILD_DIR/lib/monodoc \
  $BUILD_DIR/lib/libmono-profiler-* \
  $BUILD_DIR/share/{man,doc,info} \
  $BUILD_DIR/include

FROM debian:trixie-slim AS base

COPY --from=build /mono-build /usr/local
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf \
  && ldconfig
 

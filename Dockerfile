FROM debian:bookworm AS build

WORKDIR /tmp

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        clang \
        cmake \
        git \
        meson \
        ninja-build \
        pkg-config \
        python3 \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recurse-submodules https://github.com/EndPositive/slipstream.git src/slipstream

WORKDIR /tmp/src/slipstream

RUN meson setup --buildtype=release -Db_lto=true --warnlevel=0 build \
    && meson compile -C build

FROM debian:bookworm-slim AS final

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 7000 --home /nonexistent --shell /usr/sbin/nologin slipstream

COPY --from=build --chown=slipstream --chmod=755 \
    /tmp/src/slipstream/build/slipstream-client /usr/local/bin/slipstream-client
COPY --from=build --chown=slipstream --chmod=755 \
    /tmp/src/slipstream/build/slipstream-server /usr/local/bin/slipstream-server

USER slipstream

ENTRYPOINT ["/usr/local/bin/slipstream-server"]

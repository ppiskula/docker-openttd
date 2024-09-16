# BUILD ENVIRONMENT
FROM debian:stable-slim AS ottd_build

ARG OPENTTD_VERSION="14.1"

# Get things ready
RUN mkdir -p /config \
    && mkdir /tmp/src

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    unzip \
    wget \
    git \
    g++ \
    make \
    cmake \
    patch \
    zlib1g-dev \
    liblzma-dev \
    liblzo2-dev \
    pkg-config

# Build OpenTTD itself
WORKDIR /tmp/src

RUN git clone https://github.com/OpenTTD/OpenTTD.git . \
    && git fetch --tags \
    && git checkout ${OPENTTD_VERSION}

# Perform the build with the build script (1.11 switches to cmake, so use a script for decision making)
RUN mkdir /tmp/build && cd /tmp/build && \
    cmake \
    -DOPTION_DEDICATED=ON \
    -DOPTION_INSTALL_FHS=OFF \
    -DCMAKE_BUILD_TYPE=release \
    -DGLOBAL_DIR=/app \
    -DPERSONAL_DIR=/ \
    -DCMAKE_BINARY_DIR=bin \
    -DCMAKE_INSTALL_PREFIX=/app \
    ../src && \
    make CMAKE_BUILD_TYPE=release -j"$(nproc)" && \
    make install

# END BUILD ENVIRONMENT
# DEPLOY ENVIRONMENT

FROM debian:stable-slim
ARG OPENTTD_VERSION="14.1"

# Setup the environment and install runtime dependencies
RUN mkdir -p /config \
    && useradd -d /config -u 911 -s /bin/false openttd \
    && apt-get update \
    && apt-get install -y \
    libc6 \
    zlib1g \
    liblzma5 \
    liblzo2-2

WORKDIR /config

# Copy the game data from the build container
COPY --from=ottd_build /app /app

# Add the entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint

# Expose the volume
RUN chown -R openttd:openttd /config /app
VOLUME /config

# Expose the gameplay port
EXPOSE 3979/tcp
EXPOSE 3979/udp

# Expose the admin port
EXPOSE 3977/tcp

# Finally, let's run OpenTTD!
USER openttd
CMD /usr/local/bin/entrypoint

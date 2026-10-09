FROM ubuntu:22.04 AS runtime

ARG WORKBENCH_VERSION=2.2.1
ARG WORKBENCH_COMMIT=01164ffa47f2778088bd6ff472ec9cd9a57f5b42
ARG WORKBENCH_ARCHIVE_SHA256=4a4cf2b8ae79fe476adabf51ece716aaad0a73991d96fb2cdee45b4edb46f9c4
ARG WORKBENCH_SOURCE_SHA256=a36a2333a342c6a93cf9eb2e949fbdffa96268e1e6cc7b42d5a468816666e123

LABEL org.opencontainers.image.title="nro Workbench runtime" \
      org.opencontainers.image.description="Connectome Workbench with a self-contained Linux GUI and rendering runtime" \
      org.opencontainers.image.source="https://github.com/CLiMBlab-Stanford/nro-workbench" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.version="${WORKBENCH_VERSION}-5" \
      org.opencontainers.image.revision="${WORKBENCH_COMMIT}"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fonts-dejavu-core \
        libdbus-1-3 \
        libegl1 \
        libfontconfig1 \
        libgl1 \
        libgl1-mesa-dri \
        libglib2.0-0 \
        libgomp1 \
        libglu1-mesa \
        libglx0 \
        libopengl0 \
        libx11-6 \
        libx11-xcb1 \
        libxau6 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxcb-shm0 \
        libxcb-sync1 \
        libxcb-util1 \
        libxcb-xfixes0 \
        libxcb-xkb1 \
        libxdmcp6 \
        libxkbcommon-x11-0 \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    archive=/tmp/workbench.zip; \
    source=/tmp/workbench-source.tar.gz; \
    curl --fail --location --output "$archive" \
        "https://www.humanconnectome.org/storage/app/media/workbench/workbench-linux64-v${WORKBENCH_VERSION}.zip"; \
    echo "${WORKBENCH_ARCHIVE_SHA256}  $archive" | sha256sum --check --strict; \
    unzip -q "$archive" -d /opt; \
    curl --fail --location --output "$source" \
        "https://github.com/Washington-University/workbench/archive/${WORKBENCH_COMMIT}.tar.gz"; \
    echo "${WORKBENCH_SOURCE_SHA256}  $source" | sha256sum --check --strict; \
    install -d /usr/share/source; \
    mv "$source" "/usr/share/source/connectome-workbench-${WORKBENCH_COMMIT}.tar.gz"; \
    rm "$archive"

ENV PATH="/opt/workbench/bin_linux64:${PATH}" \
    LC_ALL=C.UTF-8 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1 \
    WORKBENCH_VERSION=2.2.1

CMD ["wb_command", "-version"]

FROM runtime AS test

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        xauth \
        xvfb \
    && rm -rf /var/lib/apt/lists/*
COPY tests/smoke.sh /usr/local/bin/nro-workbench-smoke
RUN /usr/local/bin/nro-workbench-smoke

FROM runtime AS release

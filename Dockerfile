FROM alpine:3.15

## ARG values
ARG BUILDTIME
ARG MC_VERSION
ARG DW_LINK
ARG MC_SERVER="minecraft_server.${MC_VERSION}"

# Set version for s6 overlay
ARG S6_OVERLAY_VERSION="3.1.0.1"
ARG S6_OVERLAY_ARCH="x86_64"

# Default JDK version (please use jre-headless)
ARG JDK_VERSION="17-jre-headless"

## ARG - ENV
# Minecraft server port. Do not change.
ENV DEFAULT_MC_PORT=25565

# Absolute path of app directory
ENV APP_DIR="/app"

# Absolute path of data directory
ENV DATA_DIR="/data"

# Absolute path of STDIN fifo pipe
ENV STDIN_PIPE="${APP_DIR}/in"

# Default PUID and PGID values
ARG PUID=1000
ARG PGID=1000

# Needed to execute custom scripts. Do not change.
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

## Labels
LABEL build_version="Minecraft Server version: ${MC_VERSION} | Build-date: ${BUILDTIME}"
LABEL maintainer="adripo"
LABEL org.opencontainers.image.authors="adripo"

## Build
# Install dependencies
RUN echo "**** install runtime packages ****" && \
    apk add --no-cache \
      shadow \
      curl \
      tzdata \
      openjdk${JDK_VERSION}

# Add s6 overlay-noarch
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN rm -f /tmp/s6-overlay-noarch.tar.xz
# Add s6 overlay-arch
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz
RUN rm -f /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz

# Create abc user
RUN echo "**** create abc user and group ****" && \
    addgroup -g ${PGID} abc && \
    adduser -u ${PUID} -G abc -h ${APP_DIR} -D abc

# Create data dir
RUN echo "**** create data directory ****" && \
    mkdir -p ${DATA_DIR} && \
    chown abc:abc ${DATA_DIR}

# Set workdir
WORKDIR ${APP_DIR}

## Setup server
# Setup server as abc user
USER abc

# Setup server
RUN echo "**** setup server ****"
COPY --chown=abc:abc server-setup.sh .
RUN chmod +x server-setup.sh
RUN ./server-setup.sh
RUN rm -f server-setup.sh

# Cleanup
RUN rm -rf /tmp/*

## Setup services
# Start as root
USER root

# Add local files
COPY root/ /
# Set correct permissions on scripts
RUN chmod +x /etc/s6-overlay/scripts/*

## Extra config
# Healthcheck
HEALTHCHECK --interval=2m30s --timeout=10s --retries=2 --start-period=5m \
    CMD netstat -tln | grep -q -c ${DEFAULT_MC_PORT} || exit 1

# Volume mount point
VOLUME ${DATA_DIR}

# Expose port
EXPOSE ${DEFAULT_MC_PORT}

# Startup
ENTRYPOINT ["/init"]

FROM alpine:3.15

# ARG values
ARG BUILDTIME
ARG MC_VERSION
ARG DW_LINK
ARG MC_SERVER="minecraft_server.${MC_VERSION}"

# Minecraft server port. Do not change.
ARG DEFAULT_MC_PORT=25565
ENV DEFAULT_MC_PORT="${DEFAULT_MC_PORT}"

# Set version for s6 overlay
ARG S6_OVERLAY_VERSION="3.1.0.1"
ARG S6_OVERLAY_ARCH="x86_64"

# ARG - ENV
# Absolute path of app directory
ARG APP_DIR="/app"
ENV APP_DIR="${APP_DIR}"

# Absolute path of data directory
ARG DATA_DIR="/data"
ENV DATA_DIR="${DATA_DIR}"

# Absolute path of STDIN fifo pipe
ARG STDIN_PIPE="${APP_DIR}/in"
ENV STDIN_PIPE="${STDIN_PIPE}"

# ENV default values
ENV PUID=1000
ENV PGID=1000
ENV JVM_XMS=1G
ENV JVM_XMX=4G

# Needed to execute custom scripts. Do not change.
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

# Labels
LABEL build_version="Minecraft Server version: ${MC_VERSION} Build-date: ${BUILDTIME}"
LABEL maintainer="adripo"
LABEL org.opencontainers.image.authors="adripo"


# Install dependencies
RUN echo "**** install runtime packages ****" && \
    apk add --no-cache \
      shadow \
      curl \
      tzdata \
      openjdk17-jre-headless

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


# Start as root
USER root

# Add local files
COPY root/ /

# Set correct permissions
RUN chmod +x /root/etc/s6-overlay/scripts/*


# Healthcheck
HEALTHCHECK --interval=2m30s --timeout=10s --retries=2 --start-period=5m \
    CMD netstat -tln | grep -q -c ${DEFAULT_MC_PORT} || exit 1

# Volume mount point
VOLUME ${DATA_DIR}

# Expose port
EXPOSE ${DEFAULT_MC_PORT}

# Startup
ENTRYPOINT ["/init"]

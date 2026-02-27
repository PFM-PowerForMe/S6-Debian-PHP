# 构建时
ARG IMAGE_VERSION="8.4"
FROM docker.io/library/php:${IMAGE_VERSION}-fpm AS builder
ARG REPO
# eg. amd64 | arm64
ARG ARCH
# eg. x86_64 | aarch64
ARG CPU_ARCH
# eg. latest
ARG IMAGE_VERSION
ENV REPO=$REPO \
     ARCH=$ARCH \
     CPU_ARCH=$CPU_ARCH \
     IMAGE_VERSION=$IMAGE_VERSION \
     IPE_LZF_BETTERCOMPRESSION=1

COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    COMMON_EXTS=" \
        amqp \
        apcu \
        bcmath \
        brotli \
        bz2 \
        calendar \
        dba \
        exif \
        ffi \
        gd \
        gettext \
        gmp \
        igbinary \
        imagick \
        intl \
        memcached \
        mongodb \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        redis \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        uuid \
        xmldiff \
        xmlrpc \
        zip \
        zstd \
    "; \
    \
    VERSION_EXTS=""; \
    \
    case "$IMAGE_VERSION" in \
        "8.5") \
            VERSION_EXTS="" \
            ;; \
        "8.4") \
            VERSION_EXTS="" \
            ;; \
        "8.3") \
            VERSION_EXTS="" \
            ;; \
        "8.2") \
            VERSION_EXTS="" \
            ;; \
        "8.1") \
            VERSION_EXTS="" \
            ;; \
        "8.0") \
            VERSION_EXTS="" \
            ;; \
        "7.4") \
            VERSION_EXTS="apcu_bc" \
            ;; \
        *) \
            echo "Warning: Unhandled or custom PHP version: $IMAGE_VERSION" \
            ;; \
    esac; \
    \
    echo "=========================================================="; \
    echo "Building for PHP $IMAGE_VERSION"; \
    echo "Installing extensions: $COMMON_EXTS $VERSION_EXTS"; \
    echo "=========================================================="; \
    install-php-extensions $COMMON_EXTS $VERSION_EXTS


FROM ghcr.io/pfm-powerforme/s6:latest AS s6
FROM ghcr.io/pfm-powerforme/s6-debian:latest AS s6-debian
FROM ghcr.io/pfm-powerforme/base-caddy:latest AS caddy

# 运行时
FROM scratch AS runtime
ARG IMAGE_VERSION
ENV PATH="/command:/pfm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
     S6_LOGGING_SCRIPT="n2 s1000000 T" \
     DEBIAN_FRONTEND="noninteractive" \
     TZ="Asia/Shanghai" \
     LC_ALL="C.UTF-8" \
     LANG="C.UTF-8" \
     TERM="xterm-256color" \
     COLORTERM="truecolor" \
     EDITOR="nvim" \
     VISUAL="nvim" \
     TMPDIR="/tmp" \
     TEMP="/tmp" \
     TMP="/tmp" \
     HISTCONTROL="ignoredups" \
     HISTSIZE="1000" \
     HISTFILESIZE="1000" \
     PHP_VERSION=$IMAGE_VERSION \
     CR_CADDY_WORK_DIR=/var/www

COPY --from=builder / /
COPY --from=s6 / /
COPY --from=s6-debian /pfm /pfm
COPY --from=s6-debian /etc/s6-overlay /etc/s6-overlay
COPY --from=s6-debian /etc/sudoers.d /etc/sudoers.d
# 工具
COPY --from=ghcr.io/pfm-powerforme/cli-envsubst:latest / /
COPY --from=ghcr.io/pfm-powerforme/cli-dasel:latest / /
COPY --from=caddy / /
COPY rootfs/ /
RUN /pfm/bin/fpm_init && /pfm/bin/fpm_init install libfcgi-bin
RUN /pfm/bin/fix_env

WORKDIR /var/www/
VOLUME /var/www/
EXPOSE 8080
ENTRYPOINT ["/init"]
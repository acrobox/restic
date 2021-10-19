FROM golang:alpine AS builder
ARG RESTIC_VERSION="0.12.1"
ENV CGO_ENABLED=0
WORKDIR /build
RUN set -eu; \
  archive="restic-${RESTIC_VERSION}.tar.gz"; \
  checksums="SHA256SUMS"; \
  wget --quiet "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic-${RESTIC_VERSION}.tar.gz"; \
  wget --quiet "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/$checksums"; \
  grep "$archive" "$checksums" | sha256sum -c -s; \
  if [ $? -ne 0 ]; then echo 'restic checksum is not valid' >&2; exit 1; fi; \
  tar -zxf "$archive" --strip-components=1; \
  rm -f "$archive"; \
  rm -f "$checksums"
RUN go run -mod=vendor build.go

FROM ghcr.io/acrobox/docker/minimal:latest
ENV RESTIC_CACHE_DIR="/cache"
VOLUME /data
VOLUME /cache
COPY --from=builder /build/restic /usr/local/bin/restic
USER user
ENTRYPOINT ["/usr/local/bin/restic"]
CMD ["help"]

LABEL org.opencontainers.image.source https://github.com/acrobox/restic

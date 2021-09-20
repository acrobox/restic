FROM golang:alpine AS builder
ARG RESTIC_VERSION="0.12.1"
ENV CGO_ENABLED=0
RUN apk add --no-cache ca-certificates mailcap tzdata
RUN adduser -u 1000 -S user
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

FROM alpine:latest
ENV RESTIC_CACHE_DIR="/cache"
VOLUME /data
VOLUME /cache
COPY --from=builder /etc/group /etc/group
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/mime.types /etc/mime.types
COPY --from=builder /usr/share/zoneinfo/ /usr/share/zoneinfo/
COPY --from=builder /build/restic /usr/local/bin/restic
COPY --from=builder --chown=user:nobody /home/user /tmp
USER user
ENTRYPOINT ["/usr/local/bin/restic"]
CMD ["help"]

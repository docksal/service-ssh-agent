FROM alpine:3.14

# amd64 / arm64
ARG TARGETARCH

RUN set -xe; \
	apk add --update --no-cache \
		bash \
		openssh \
		socat \
	; \
	rm -rf /var/cache/apk/*

COPY bin /usr/local/bin
COPY healthcheck.sh /opt/healthcheck.sh

ENV \
	SSH_DIR=/.ssh \
	SOCKET_DIR=/.ssh-agent \
	SSH_AUTH_SOCK=${SOCKET_DIR}/socket \
	SSH_AUTH_PROXY_SOCK=${SOCKET_DIR}/proxy-socket

VOLUME ${SOCKET_DIR}

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["ssh-agent"]

# Health check script
HEALTHCHECK --interval=5s --timeout=1s --retries=3 CMD ["/opt/healthcheck.sh"]

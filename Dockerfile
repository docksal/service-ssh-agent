FROM alpine:3.8

RUN apk add --no-cache \
	bash \
	openssh \
	socat \
	&& rm -rf /var/cache/apk/*

COPY bin /usr/local/bin
COPY healthcheck.sh /opt/healthcheck.sh

ENV SSH_DIR /.ssh
ENV SOCKET_DIR /.ssh-agent
ENV SSH_AUTH_SOCK ${SOCKET_DIR}/socket
ENV SSH_AUTH_PROXY_SOCK ${SOCKET_DIR}/proxy-socket

VOLUME ${SOCKET_DIR}

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["ssh-agent"]

# Health check script
HEALTHCHECK --interval=5s --timeout=1s --retries=3 CMD ["/opt/healthcheck.sh"]

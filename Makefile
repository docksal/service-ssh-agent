-include env_make

VERSION ?= dev

REPO = docksal/ssh-agent
NAME = docksal-ssh-agent

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean release

build:
	docker build -t ${REPO}:${VERSION} .

test:
	IMAGE=${REPO}:${VERSION} bats tests/test.bats

push:
	docker push ${REPO}:${VERSION}

exec:
	@docker exec ${NAME} ${CMD}

exec-it:
	@docker exec -it ${NAME} ${CMD}

shell:
	@make exec-it -e CMD=sh

run: clean
	docker run --rm -it ${REPO}:${VERSION} sh

# This is the only place where fin is used/necessary
start:
	IMAGE_SSH_AGENT=${REPO}:${VERSION} fin system reset ssh-agent

stop:
	docker stop ${NAME}

logs:
	docker logs ${NAME}

logs-follow:
	docker logs -f ${NAME}

debug: build start logs-follow

release:
	@scripts/release.sh

clean:
	docker rm -vf ${NAME} || true

default: build

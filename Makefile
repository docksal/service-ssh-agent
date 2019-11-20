# Allow using a different docker binary
DOCKER ?= docker

VERSION ?= dev

REPO = docksal/ssh-agent
NAME = docksal-ssh-agent

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean release

build:
	$(DOCKER) build -t ${REPO}:${VERSION} .

test:
	IMAGE=${REPO}:${VERSION} bats tests/test.bats

push:
	$(DOCKER) push ${REPO}:${VERSION}

exec:
	@$(DOCKER) exec ${NAME} ${CMD}

exec-it:
	@$(DOCKER) exec -it ${NAME} ${CMD}

shell:
	@make exec-it -e CMD=sh

run: clean
	$(DOCKER) run --rm -it ${REPO}:${VERSION} sh

# This is the only place where fin is used/necessary
start:
	IMAGE_SSH_AGENT=${REPO}:${VERSION} fin system reset ssh-agent

stop:
	$(DOCKER) stop ${NAME}

logs:
	$(DOCKER) logs ${NAME}

logs-follow:
	$(DOCKER) logs -f ${NAME}

debug: build start logs-follow

release:
	@scripts/docker-push.sh

clean:
	$(DOCKER) rm -vf ${NAME} || true

default: build

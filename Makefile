# Allow using a different docker binary
DOCKER ?= docker

VERSION ?= dev
BUILD_TAG ?= $(VERSION)
REPO = docksal/ssh-agent
NAME = docksal-ssh-agent

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean release

build:
	$(DOCKER) build -t ${REPO}:${BUILD_TAG} .

test:
	IMAGE=${REPO}:${BUILD_TAG} bats tests/test.bats

push:
	$(DOCKER) push ${REPO}:${BUILD_TAG}

exec:
	@$(DOCKER) exec ${NAME} ${CMD}

exec-it:
	@$(DOCKER) exec -it ${NAME} ${CMD}

shell:
	@make exec-it -e CMD=sh

run: clean
	$(DOCKER) run --rm -it ${REPO}:${BUILD_TAG} sh

# This is the only place where fin is used/necessary
start:
	IMAGE_SSH_AGENT=${REPO}:${BUILD_TAG} fin system reset ssh-agent

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

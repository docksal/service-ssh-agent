# Allow using a different docker binary
DOCKER ?= docker

# Force BuildKit mode for builds
# See https://docs.docker.com/buildx/working-with-buildx/
DOCKER_BUILDKIT=1

IMAGE ?= docksal/ssh-agent
BUILD_IMAGE_TAG ?= $(IMAGE):build
NAME = docksal-ssh-agent

# Make it possible to pass arguments to Makefile from command line
# https://stackoverflow.com/a/6273809/1826109
ARGS = $(filter-out $@,$(MAKECMDGOALS))

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean

default: build

build:
	$(DOCKER) build -t $(BUILD_IMAGE_TAG) .

test:
	IMAGE=$(BUILD_IMAGE_TAG) tests/test.bats

push:
	$(DOCKER) push $(BUILD_IMAGE_TAG)

conf-vhosts:
	make exec -e CMD='cat /etc/nginx/conf.d/vhosts.conf'

# This is the only place where fin is used/necessary
start: clean
	IMAGE_SSH_AGENT=$(BUILD_IMAGE_TAG) fin system reset ssh-agent

exec:
	$(DOCKER) exec $(NAME) bash -lc "$(CMD)"

exec-it:
	@$(DOCKER) exec -it $(NAME) bash -lic "$(CMD)"

shell:
	@make exec-it -e CMD=bash

stop:
	$(DOCKER) stop $(NAME)

logs:
	$(DOCKER) logs $(NAME)

logs-follow:
	$(DOCKER) logs -f $(NAME)

debug: build start logs-follow

clean:
	$(DOCKER) rm -vf $(NAME) &>/dev/null || true

# Make it possible to pass arguments to Makefile from command line
# https://stackoverflow.com/a/6273809/1826109
%:
	@:

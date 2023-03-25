SHELL = /bin/sh

DOCKER ?= docker

DOCKER_IMAGE = repro-pytype-import-error-pydantic

.PHONY: image/dev
image/dev: Dockerfile
	$(DOCKER) build --rm --tag=$(DOCKER_IMAGE):dev --target=dev .

image: Dockerfile
	$(DOCKER) build --rm --tag=$(DOCKER_IMAGE) .

bash:
	$(DOCKER) run -it --rm \
		-u $(shell id -u):$(shell id -g) \
		--entrypoint=bash \
		-v $(realpath .):/tmp/target \
		-w /tmp/target \
		$(DOCKER_IMAGE):dev

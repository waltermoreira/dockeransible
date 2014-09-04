.PHONY: clean

IMAGE?=ansible
DOCKER?=docker
NO_CACHE?=false

build: Dockerfile
	$(DOCKER) build --no-cache=$(NO_CACHE) -t $(IMAGE) .
	touch build

clean:
	rm -rf build

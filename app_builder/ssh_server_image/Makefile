DISTROS=debian ubuntu centos

.PHONY: clean

build: Dockerfile.*
	@set -e; for distro in $(DISTROS); \
	do \
		ln -sf Dockerfile.$$distro Dockerfile; \
		docker build -t $${distro}_ssh_server . ; \
	done
	touch build
	touch .

clean:
	rm -rf build

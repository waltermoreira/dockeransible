
build:
	@set -e; for directory in $(shell ls -d */); \
	do \
		echo "Processing directory: $$directory"; \
		$(MAKE) --directory=$$directory; \
	done

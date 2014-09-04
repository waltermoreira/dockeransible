.PHONY: clean

build: app_builder_image ssh_server_image
	$(MAKE) build --directory=ssh_server_image
	$(MAKE) build --directory=app_builder_image
	touch build

clean:
	$(MAKE) clean --directory=ssh_server_image
	$(MAKE) clean --directory=app_builder_image
	rm -rf build

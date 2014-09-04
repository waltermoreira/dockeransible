.PHONY: clean

build: Dockerfile *.sh
	docker build -t app_builder .
	touch build
	touch .

clean:
	rm -rf build

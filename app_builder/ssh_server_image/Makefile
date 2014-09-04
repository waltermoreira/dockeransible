.PHONY: clean

build: Dockerfile
	docker build -t ssh_server .
	touch build
	touch .

clean:
	rm -rf build

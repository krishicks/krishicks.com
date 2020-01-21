default: build

.PHONY: build
build:
	hugo -d docs

.PHONY: server
server:
	hugo server

test_files := $(wildcard test/*.bats)

.PHONY: build test

build:
	docker build -t umweltdk/node-builder-base:0.12 base
	docker build -t umweltdk/node-builder:0.12 -f Dockerfile.default .
	docker build -t umweltdk/node-builder-bower:0.12 -f Dockerfile.bower .
	docker build -t umweltdk/node-builder-export:0.12 -f Dockerfile.export .

push:
	docker push umweltdk/node-builder-base:0.12
	docker push umweltdk/node-builder:0.12
	docker push umweltdk/node-builder-bower:0.12
	docker push umweltdk/node-builder-export:0.12

test: build
	bats/bin/bats test/*.bats

$(test_files): %.bats: build
	bats/bin/bats $@

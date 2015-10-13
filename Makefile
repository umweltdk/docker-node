node_versions := 0.12 4.1
fullVersion = $(1).$(shell curl -sSL --compressed 'http://nodejs.org/dist' | grep '<a href="v'"$(1)." | sed -E 's!.*<a href="v([^"/]+)/?".*!\1!' | cut -f 3 -d . | sort -n | tail -1)

all_versions := latest 4 $(node_versions) $(foreach version,$(node_versions),$(call fullVersion,$(version)))

tests := $(basename $(notdir $(wildcard test/*.bats)))

.PHONY: build test clean

build: $(foreach version,$(all_versions),build-$(version))
test: $(foreach version,$(all_versions),test-all-$(version))
push: $(foreach version,$(all_versions),push-$(version))
clean:
	rm -rf dist test/tmp

dist:
	mkdir -p dist

dist/Dockerfile.base.%: Dockerfile | dist
	cp $< $@.tmp
	sed -E -i 's/^(FROM .+:).*/\1$*/;' "$@.tmp"
	mv $@.tmp $@

dist/Dockerfile.onbuild.%: Dockerfile.onbuild | dist
	cp $< $@.tmp
	sed -E -i 's/^(FROM .+:).*/\1$*/;' "$@.tmp"
	mv $@.tmp $@

dist/Dockerfile.onbuild-bower.%: Dockerfile.onbuild-bower | dist
	cp $< $@.tmp
	sed -E -i 's/^(FROM .+:).*/\1$*/;' "$@.tmp"
	mv $@.tmp $@


build-%: dist/Dockerfile.base.% dist/Dockerfile.onbuild.% dist/Dockerfile.onbuild-bower.%
	docker build --pull -t umweltdk/node:$* -f dist/Dockerfile.base.$* .
	docker build -t umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild -f dist/Dockerfile.onbuild.$* .
	docker build -t umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild-bower -f dist/Dockerfile.onbuild-bower.$* .

push-%:
	docker push umweltdk/node:$*
	docker push umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild
	docker push umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild-bower

test-all-%:
	NODE_VERSION=$* bats/bin/bats test/*.bats

$(foreach test,$(tests),run-test-$(test)-%):
	NODE_VERSION=$* bats/bin/bats test/$(subst -$*,,$(subst run-test-,,$@)).bats

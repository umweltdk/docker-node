image := umweltdk/node
node_versions := 0.12 4 5 6 7 8 9
node_old1_versions := 0.12 4
node_old2_versions := 5 6
node_old3_versions := 7
node_latest_version := $(shell curl -sSL --compressed "http://nodejs.org/dist/latest" | grep '<a href="node-v'"$1." | sed -E 's!.*<a href="node-v([0-9.]+)-.*".*!\1!' | head -1)
node_lts_version := $(shell curl -sSL --compressed "https://nodejs.org/en/" | egrep '<a .* title=".* LTS"' | sed -E 's!.*data-version="v([0-9.]+)".*!\1!')

comma:= ,
empty:=
space:= $(empty) $(empty)
nodeFullVersion = $(shell curl -sSL --compressed "http://nodejs.org/dist/latest-v$1.x/" | grep '<a href="node-v'"$1." | sed -E 's!.*<a href="node-v([0-9.]+)-.*".*!\1!' | head -1)
nodeMajorVersion = $(subst $(space),.,$(wordlist 1,$(if $(subst 0,,$(word 1,$(subst ., ,$(1)))),1,2),$(subst ., ,$(1))))
nodeVersion = $(word 2,$(subst -, ,$(1)))
node_latest_major := $(call nodeMajorVersion,$(node_latest_version))
node_lts_major := $(call nodeMajorVersion,$(node_lts_version))

tests := $(basename $(notdir $(wildcard test/*.bats)))

.PHONY: build test clean default

default: build test
build: build-latest build-lts build-old
test: test-all-latest test-all-lts test-all-old
push: push-latest push-lts push-old
clean:
	rm -rf dist test/tmp

dist:
	mkdir -p dist


build-latest: build-$(node_latest_version) build-$(node_latest_major) | dist
	mkdir -p dist/v$(node_latest_version)
	docker tag $(image):$(node_latest_version) $(image):latest
	docker tag $(image):$(node_latest_version)-onbuild $(image):onbuild
	docker tag $(image):$(node_latest_version)-onbuild-bower $(image):onbuild-bower
	echo latest >> dist/v$(node_latest_version)/images.txt
	echo onbuild >> dist/v$(node_latest_version)/images-onbuild.txt
	echo onbuild-bower >> dist/v$(node_latest_version)/images-onbuild-bower.txt

build-lts: build-$(node_lts_version) build-$(node_lts_major) | dist
	mkdir -p dist/v$(node_lts_version)
	docker tag $(image):$(node_lts_version) $(image):lts
	docker tag $(image):$(node_lts_version)-onbuild $(image):lts-onbuild
	docker tag $(image):$(node_lts_version)-onbuild-bower $(image):lts-onbuild-bower
	echo lts >> dist/v$(node_lts_version)/images.txt
	echo lts-onbuild >> dist/v$(node_lts_version)/images-onbuild.txt
	echo lts-onbuild-bower >> dist/v$(node_lts_version)/images-onbuild-bower.txt

build-old1:
	$(MAKE) $(foreach node,$(node_old1_versions),build-$(node))

build-old2:
	$(MAKE) $(foreach node,$(node_old2_versions),build-$(node))

build-old3:
	$(MAKE) $(foreach node,$(node_old3_versions),build-$(node))

$(foreach node,$(node_versions),build-$(node)): | dist
	$(MAKE) build-$(call nodeFullVersion,$(subst build-,,$@))
	echo $(subst build-,,$@) >> dist/v$(call nodeFullVersion,$(subst build-,,$@))/images.txt
	echo $(subst build-,,$@)-onbuild >> dist/v$(call nodeFullVersion,$(subst build-,,$@))/images-onbuild.txt
	echo $(subst build-,,$@)-onbuild-bower >> dist/v$(call nodeFullVersion,$(subst build-,,$@))/images-onbuild-bower.txt
	mkdir -p dist/v$(call nodeFullVersion,$(subst build-,,$@))
	echo $(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst build-,,$@))))) >> dist/v$(call nodeFullVersion,$(subst build-,,$@))/images.txt
	echo $(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst build-,,$@)))))-onbuild >> dist/v$(call nodeFullVersion,$(subst build-,,$@))/images-onbuild.txt
	echo $(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst build-,,$@)))))-onbuild-bower >> dist/v$(call nodeFullVersion,$(subst build-,,$@))/images-onbuild-bower.txt
	docker tag $(image):$(call nodeFullVersion,$(subst build-,,$@)) $(image):$(subst build-,,$@)
	docker tag $(image):$(call nodeFullVersion,$(subst build-,,$@))-onbuild $(image):$(subst build-,,$@)-onbuild
	docker tag $(image):$(call nodeFullVersion,$(subst build-,,$@))-onbuild-bower $(image):$(subst build-,,$@)-onbuild-bower
	docker tag $(image):$(call nodeFullVersion,$(subst build-,,$@)) $(image):$(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst build-,,$@)))))
	docker tag $(image):$(call nodeFullVersion,$(subst build-,,$@))-onbuild $(image):$(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst build-,,$@)))))-onbuild
	docker tag $(image):$(call nodeFullVersion,$(subst build-,,$@))-onbuild-bower $(image):$(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst build-,,$@)))))-onbuild-bower

dist/Dockerfile.base.%: Dockerfile | dist
	cp $< $@.tmp
	sed -E -i.bak 's/^(FROM .+:).*/\1$*/;' "$@.tmp"
	rm "$@.tmp.bak"
	mv $@.tmp $@

dist/Dockerfile.onbuild.%: Dockerfile.onbuild | dist
	cp $< $@.tmp
	sed -E -i.bak 's/^(FROM .+:).*/\1$*/;' "$@.tmp"
	rm "$@.tmp.bak"
	mv $@.tmp $@

dist/Dockerfile.onbuild-bower.%: Dockerfile.onbuild-bower | dist
	cp $< $@.tmp
	sed -E -i.bak 's/^(FROM .+:).*/\1$*/;' "$@.tmp"
	rm "$@.tmp.bak"
	mv $@.tmp $@


build-%: dist/Dockerfile.base.% dist/Dockerfile.onbuild.% dist/Dockerfile.onbuild-bower.% | dist
	mkdir -p dist/v$*
	docker build --pull -t umweltdk/node:$* -f dist/Dockerfile.base.$* .
	docker build -t umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild -f dist/Dockerfile.onbuild.$* .
	docker build -t umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild-bower -f dist/Dockerfile.onbuild-bower.$* .
	echo $* >> dist/v$*/images.txt
	echo $*-onbuild >> dist/v$*/images-onbuild.txt
	echo $*-onbuild-bower >> dist/v$*/images-onbuild-bower.txt

push-latest: push-$(node_latest_major)

push-lts: push-$(node_lts_major)

push-old1: 
	$(MAKE) $(foreach node,$(node_old1_versions),push-$(node))

push-old2: 
	$(MAKE) $(foreach node,$(node_old2_versions),push-$(node))

push-old3: 
	$(MAKE) $(foreach node,$(node_old3_versions),push-$(node))

$(foreach node,$(node_versions),push-$(node)):
	$(MAKE) real-push-$(subst push-,,$@)
	$(MAKE) push-$(call nodeFullVersion,$(subst push-,,$@))
	[ "$(subst push-,,$@)" == "0.12" ] || $(MAKE) push-$(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst push-,,$@)))))

push-%:
	$(MAKE) real-push-$*

real-push-%:
	docker push umweltdk/node:$*
	docker push umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild
	docker push umweltdk/node:$(if $(subst latest,,$*),$*-,)onbuild-bower

test-all-latest: test-all-$(node_latest_major)
test-all-lts: test-all-$(node_lts_major)

test-all-old1:
	$(MAKE) $(foreach node,$(node_old1_versions),test-all-$(node))

test-all-old2:
	$(MAKE) $(foreach node,$(node_old2_versions),test-all-$(node))

test-all-old3:
	$(MAKE) $(foreach node,$(node_old3_versions),test-all-$(node))

$(foreach node,$(node_versions),test-all-$(node)):
	$(MAKE) real-test-all-$(subst test-all-,,$@)
	$(MAKE) test-all-$(call nodeFullVersion,$(subst test-all-,,$@))
	[ "$(subst test-all-,,$@)" == "0.12" ] || $(MAKE) test-all-$(subst $(space),.,$(wordlist 1,2,$(subst ., ,$(call nodeFullVersion,$(subst test-all-,,$@)))))

test-all-%:
	$(MAKE) real-test-all-$*

real-test-all-%:
	NODE_VERSION=$* bats/bin/bats test/*.bats

$(foreach test,$(tests),run-test-$(test)-%):
	NODE_VERSION=$* bats/bin/bats test/$(subst -$*,,$(subst run-test-,,$@)).bats

README.md: README.header.md README.footer.md $(foreach version,$(notdir $(wildcard dist/v*)),README.md-$(version))
	cp README.header.md README.md
	$(MAKE) $(foreach version,$(notdir $(wildcard dist/v*)),README.md-$(version))
	cat README.footer.md >> README.md

README.md-%:
	echo '- [$(shell sort dist/$*/images.txt | uniq | sed -E 's/(.+)/`\1`/' | tr '\n' , | sed -E 's/,/, /g') (*Dockerfile*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile)' >> README.md
	echo '- [$(shell sort dist/$*/images-onbuild.txt | uniq | sed -E 's/(.+)/`\1`/' | tr '\n' , | sed -E 's/,/, /g') (*Dockerfile.onbuild*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild)' >> README.md
	echo '- [$(shell sort dist/$*/images-onbuild-bower.txt | uniq | sed -E 's/(.+)/`\1`/' | tr '\n' , | sed -E 's/,/, /g') (*Dockerfile.onbuild-bower*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild-bower)' >> README.md


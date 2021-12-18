TAG = "Makefile"

VERSION	= $(shell cat ./VERSION)
MODULE = service-batch-statistics
DIST_BUCKET = s3://udon-infra/codebuild-artifact
BUILT_ARTIFACT = $(MODULE)-$(VERSION)-all.jar
DIST_ARTIFACT = $(MODULE)-$(VERSION).jar

.PHONY: test
test:
	@ echo "[$(TAG)] ($$(date -u '+%H:%M:%S')) - Building : $(MODULE)"
	@ echo ""

	@ ../gradlew :$(MODULE):test

.PHONY: build
build:
	@ echo "[$(TAG)] ($$(date -u '+%H:%M:%S')) - Building : $(MODULE)"
	@ echo ""

	@ ../gradlew :$(MODULE):clean :$(MODULE):shadowJar

.PHONY: deploy
deploy:
	@ echo "[$(TAG)] ($$(date -u '+%H:%M:%S')) - Deploying: $(MODULE)"
	@ echo ""

	@ aws s3 cp build/libs/$(BUILT_ARTIFACT) $(DIST_BUCKET)/$(MODULE)/$(DIST_ARTIFACT)

##
# Dockerfile for dice application

# Our docker Hub account name
# HUB_NAMESPACE = "<hub_name>"

CUR_DIR = $(shell echo "${PWD}")
MKFILE_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

##
# Image parameters
SOURCE:= "dice.dockerfile"
AUTHOR:= sk3l
REPO:=   dice
IMAGE:=  $(AUTHOR)/$(REPO)
TAG?=    latest

# Assign development user name passed to container
DEV_USER?= $(shell echo "${USER}")
DEV_USER_OPTS:=--build-arg dev_user=$(DEV_USER)

# Establish bind mount between host and container
# (default=nothing shared)
MNT_OPTS:=-v :/home/$(DEV_USER)/code
CODE_DIR_VAR:=CODE_DIR
ifdef $(CODE_DIR_VAR)
    MNT_OPTS=-v $(CODE_DIR):/home/$(DEV_USER)/code:shared
endif

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

##
# Docker rules

##
# Target handling execution of 'docker build'
.PHONY: build
build: ## Build the container image for dice
	@docker build             \
		--tag $(IMAGE):$(TAG) \
		$(DEV_USER_OPTS)      \
		-f $(SOURCE)          \
		.

##
# Target for validating image definition
.PHONY: check
check: ## Verify integrity of dice image
	@image_hash=$(shell docker images -q $(IMAGE):$(TAG)); \
	if [ -z "$$image_hash" ]; then \
	echo "ERROR: couldn't locate image $(IMAGE):$(TAG) (have you run 'make build'?)"; \
		exit 1; \
	fi

##
# Target for inspecting dice image tags
.PHONY: ls
ls: ## List dice image inventory
	@docker images $(IMAGE)

##
# Target handling execution of 'docker run'
.PHONY: run
run: check ## Run container instance of dice
	@docker run     \
		--rm        \
		-i          \
		--tty       \
		$(MNT_OPTS) \
		$(IMAGE):$(TAG)

##
# Target handling execution of 'docker rmi'
.PHONY: rmi
rmi: check ## Remove the dice container image
	@docker rmi $(IMAGE):$(TAG)

clean: rmi

## Full versioned release
#
release: build tag publish ## Build and publish dice to the container registry

##
# Targets handling execution of 'docker push'
publish: login check publish-latest publish-version ## Publish to container registry

publish-latest: tag-latest ## Publish the `latest` taged container to container registry
	@echo 'Publishing latest to container registry'
	docker push $(IMAGE):latest

publish-version: tag-version ## Publish the `{version}` taged container to container registry
	@echo 'Publishing $(IMAGE):$(TAG) to container registry'
	docker push $(IMAGE):$(TAG)

##
# Targets handling execution of 'docker tag'
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

.PHONY: tag-latest
tag-latest: check ## Generate container `{version}` tag
	@docker tag $(IMAGE) $(IMAGE):latest
	@echo "Tagged version 'latest'"

.PHONY: tag-version
tag-version: check ## Generate container `latest` tag
	@git_tag=$(shell git describe --tags --always --abbrev=0 | grep -e "[0-9]\+\.[0-9]\+"); \
	if [ -z $$git_tag ]; then \
		echo "ERROR: missing or invalid Git tag (have you run 'git tag'?)"; exit 1; \
	fi; \
	docker tag $(IMAGE) $(IMAGE):$$git_tag; \
	echo "Tagged version $$git_tag"

.PHONY: login
login:
	@docker login
# HELPERS


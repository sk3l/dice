##
# Makefile for dice application

# Our docker Hub account name
# HUB_NAMESPACE = "<hub_name>"

CUR_DIR:= $(shell echo "${PWD}")
MKFILE_DIR:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
INSTALL_DIR?= /home/${USER}/.local/bin

##
# Image parameters
SOURCE:= "dice.dockerfile"
AUTHOR:= sk3l
REPO:=   dice
IMAGE:=  $(AUTHOR)/$(REPO)
NAME:=   $(REPO)
TAG?=    latest

# Assign development user name passed to container
PROJECT_USER?=$(shell echo "${USER}")

# Assign name for development session
PROJECT_NAME?=$(shell echo "dice-$$(date +%Y%m%d-%H%M%S)")

# Assign location of host's project directory for use in the container
# (default=no shared project directory)
PROJECT_PATH?=

# Assign location of development user's SSH directory for use in the container
# (default=.ssh directory under current user's $HOME)
SSH_PATH?=$(shell echo "${HOME}/.ssh")

# Assign arguments for image build
IMAGE_ARGS?=--build-arg dev_user=$(PROJECT_USER)

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
		$(IMAGE_ARGS)         \
		-f $(SOURCE)          \
		.

##
# Target handling execution of 'docker build'; FORCE new, clean image build
.PHONY: rebuild
rebuild: ## Build the container image for dice
	@docker build             \
		--no-cache            \
		--tag $(IMAGE):$(TAG) \
		$(IMAGE_ARGS)         \
		-f $(SOURCE)          \
		.

##
# Target handling execution of 'docker build'
.PHONY: install
install: ## Install dice
	@echo "Installing dice at $(INSTALL_DIR)"
	@mkdir -p $(INSTALL_DIR) && \
	cp $(MKFILE_DIR)/dice $(INSTALL_DIR)

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
	@project_mount=; \
	if [ -d $(PROJECT_PATH) ] && [ -x $(PROJECT_PATH) ]; then \
		project_mount="-v $(PROJECT_PATH):/home/$(PROJECT_USER)/$(PROJECT_NAME):shared"; \
	fi; \
	ssh_mount=; \
	if [ -d $(SSH_PATH) ] && [ -x $(SSH_PATH) ]; then \
		ssh_mount=-"v $(SSH_PATH):/home/${PROJECT_USER}/.ssh:shared"; \
	fi; \
	docker run                 \
		--rm                   \
		-i                     \
		--tty                  \
		--name $(PROJECT_NAME) \
		--privileged           \
		$$project_mount        \
		$$ssh_mount            \
		$(IMAGE):$(TAG);

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


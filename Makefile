NAME=aws-ecs-blue-green-deployment
IMG_TAG?=latest

.PHONY: help
DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build or rebuild services
	IMG_TAG=${IMG_TAG} docker-compose build

build_blue: ## Build or rebuild services
	@BG_COLOR="#00f" IMG_TAG=`git rev-parse --short HEAD` docker-compose build

build_green: ## Build or rebuild services for blue
	@BG_COLOR="#080" IMG_TAG=green-`git rev-parse --short HEAD` docker-compose build

up: ## Create and start containers
	docker-compose up

push: build ## Push images
	IMG_TAG=${IMG_TAG} docker-compose push

ecs_taskdef_create: ## Create ECS Task Def
	$(call taskdef_create,${NAME},${IMG_TAG},"#00f",docker-compose.yml,ecs-params.yml)
	$(call taskdef_create,${NAME},${IMG_TAG},"#080",docker-compose.yml,ecs-params.yml)

define taskdef_create
@IMG_TAG=$(2) \
	BG_COLOR=$(3) \
	ecs-cli \
	compose \
	--project-name $(1) \
	--file $(4) \
	--ecs-params $(5) \
	create
endef

define service_update
$(eval TASKDEF_ARN := $(shell aws ecs describe-task-definition --task-definition $(1) --query "taskDefinition.taskDefinitionArn" --output text))
@aws ecs \
	update-service \
	--cluster $(1) \
	--service $(1) \
	--task-definition ${TASKDEF_ARN} \
	--force-new-deployment
endef

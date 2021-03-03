.PHONY: help
DEFAULT_GOAL := help

help:
	$(call show_help)

build: ## Build or rebuild services
	docker-compose build

up: ## Create and start containers
	docker-compose up

define show_help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
endef

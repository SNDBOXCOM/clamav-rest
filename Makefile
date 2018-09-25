REPO=clamav
NAME=clamav-rest
BUILD=latest
AWS_ACCOUNT_ID=505166527770
REGION=us-east-2

build: ## Build docker image
	docker build -t $(REPO):$(NAME)-$(BUILD) .

.PHONY: tags
tags:
	docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" $(REPO)

.PHONY: push
push: build ## Push docker image to docker registry
	@echo "===> Pushing $(REPO):$(NAME)-$(BUILD) to aws ecr..."
	@eval $$(aws ecr get-login --no-include-email --region $(REGION))
	# Build and push the image
	@docker tag $(REPO):$(NAME)-$(BUILD) $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO):$(NAME)-$(BUILD)
	@docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO):$(NAME)-$(BUILD)

.PHONY: run
run: stop ## Run docker container
	@docker run --init -d --name $(NAME) $(REPO):$(NAME)-$(BUILD)

.PHONY: ssh
ssh: ## SSH into docker image
	@docker run --init -it --rm --entrypoint=sh $(REPO):$(NAME)-$(BUILD)

.PHONY: stop
stop: ## Kill running docker containers
	@docker rm -f $(NAME) || true

.PHONY: stop-all
stop-all: ## Kill ALL running docker containers
	@docker-clean stop

clean: ## Clean docker image and stop all running containers
	docker-clean stop
	docker rmi $(REPO):$(NAME)-$(BUILD) || true

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

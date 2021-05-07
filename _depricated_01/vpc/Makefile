.ONESHELL:
.SHELL := /usr/bin/bash
.PHONY: apply destroy destroy-target plan-destroy plan plan-target prep output build
BUILD_CONFIG="cloudbuild.yaml"
BUILD_DIR="."
PROJECT_NUMBER=$(shell gcloud projects describe $(PROJECT_ID) --format='value(projectNumber)')
CURRENT_FOLDER=$(shell basename "$$(pwd)")
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)
TF_CMD="terraform"
HELM_DEBUG="HELM_DEBUG=1"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
##	@if [ -z $(PROJECT) ]; then ##		echo "$(BOLD)$(RED)PROJECT was not set$(RESET)"; ##		ERROR=1; ##	fi
	@if [ -z $(SERVICE) ]; then 		echo "$(BOLD)$(RED)SERVICE was not set$(RESET)"; 		ERROR=1; 	fi
##	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then ##		echo "$(BOLD)Example usage: `CREDENTIALS=./account.json PROJECT=my_project SERVICE=vpc make plan`$(RESET)"; ##		exit 1; ##	fi

prep: ## set-env ## Prepare a new workspace (environment) if needed, configure the tfstate backend, update any modules, and switch to the workspace
##	@echo "$(BOLD)Verifying that the GCS Storage bucket $(BUCKET) for remote state exists$(RESET)"
	@if ! gsutil ls -p $(PROJECT_ID) gs://$(BUCKET) > /dev/null 2>&1 ; then 		echo "$(BOLD)BUCKET bucket $(BUCKET) was not found, create a new bucket with versioning enabled to store tfstate$(RESET)"; 		exit 1; 	else
		echo "$(BOLD)$(GREEN)BUCKET bucket $(BUCKET) exists$(RESET)"; 	fi
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@$(TF_CMD) init 		-input=false 		-reconfigure 		-upgrade 		-verify-plugins=true 		-backend=true 
plan: prep ## Show what terraform thinks it will do
	@$(TF_CMD) plan 		-input=false 		-refresh=true -detailed-exitcode
plan-target: prep ## Shows what a plan looks like for applying a specific resource
	@echo "$(YELLOW)$(BOLD)[INFO]   $(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "PLAN target: " DATA && 		$(TF_CMD) plan 			-input=true 			-refresh=true 			-target=$$DATA

plan-destroy: prep ## Creates a destruction plan.
	@$(TF_CMD) plan 		-input=false 		-refresh=true 		-destroy 
apply: prep ## Have terraform do the things. This will cost money.
	@$(HELM_DEBU) $(TF_CMD) apply 		-input=false 		-auto-approve 		-refresh=true 
destroy: prep ## Destroy the things
	@$(TF_CMD) destroy 		-input=false 		-auto-approve 		-refresh=true 
destroy-target: prep ## Destroy a specific resource. Caution though, this destroys chained resources.
	@echo "$(YELLOW)$(BOLD)[INFO] Specifically destroy a piece of Terraform data.$(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "Destroy target: " DATA && 		$(TF_CMD) destroy 		-input=false 		-auto-approve 		-refresh=true 		-target=$$DATA

output:
	@$(TF_CMD) output

build:
	@gcloud builds submit --config=cloudbuild.yaml .


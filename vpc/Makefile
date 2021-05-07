.ONESHELL:
.SHELL := /usr/bin/bash
.PHONY: apply tf-adpply destroy tf-destroy destroy-target plan-destroy plan tf-plan plan-target prep output tf-output 
BUCKET="tf-${PROJECT_ID}"
BUILD_CONFIG="cloudbuild.yaml"
BUILD_DIR="."
PROJECT=$(PROJECT_ID)
PROJECT_NUMBER=$(shell gcloud projects describe $(PROJECT_ID) --format='value(projectNumber)')
SERVICE=$(shell basename ${PWD})
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
	@if [ -z $(PROJECT) ]; then \
		echo "$(BOLD)$(RED)PROJECT was not set$(RESET)"; \
		ERROR=1; \
	fi
	@if [ -z $(SERVICE) ]; then \
		echo "$(BOLD)$(RED)SERVICE was not set$(RESET)"; \
		ERROR=1; \
	fi
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`CREDENTIALS=../credentials.json PROJECT=my_project SERVICE=project make plan\`$(RESET)"; \
		exit 1; \
	fi

prep: set-env ## Prepare a new workspace (environment) if needed, configure the tfstate backend, update any modules, and switch to the workspace
	@echo "$(BOLD)Verifying that the GCS Storage bucket $(BUCKET) for remote state exists$(RESET)" 
	# Still need to test if $(BUCKET) exists
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@$(TF_CMD) init \
		-input=false \
		-reconfigure \
		-upgrade \
		-verify-plugins=true \
		-backend=true 

tf-plan: prep ## Show what terraform thinks it will do
	@$(TF_CMD) plan \
		-input=false \
		-refresh=true 

plan-target: prep ## Shows what a plan looks like for applying a specific resource
	@echo "$(YELLOW)$(BOLD)[INFO]   $(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "PLAN target: " DATA && \
		$(TF_CMD) plan \
			-input=true \
			-refresh=true \
			-target=$$DATA

plan-destroy: prep ## Creates a destruction plan.
	@$(TF_CMD) plan \
		-input=false \
		-refresh=true \
		-destroy 

tf-apply: prep ## Have terraform do the things. This will cost money.
	@$(TF_CMD) apply \
		-input=false \
		-auto-approve \
		-refresh=true 

tf-destroy: prep ## Destroy the things
	@$(TF_CMD) destroy \
		-input=false \
		-auto-approve \
		-refresh=true 

destroy-target: prep ## Destroy a specific resource. Caution though, this destroys chained resources.
	@echo "$(YELLOW)$(BOLD)[INFO] Specifically destroy a piece of Terraform data.$(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "Destroy target: " DATA && \
		$(TF_CMD) destroy \
		-input=false \
		-auto-approve \
		-refresh=true \
		-target=$$DATA

tf-output: prep
	@$(TF_CMD) output

###
#  build targets call cloud build which runs tarraform targets
###

plan:
	@gcloud builds submit --substitutions=_BUILDSTATE="tf-plan" --config=cloudbuild.yaml .

apply:
	@gcloud builds submit --substitutions=_BUILDSTATE="tf-apply" --config=cloudbuild.yaml .

destroy:
	@gcloud builds submit --substitutions=_BUILDSTATE="tf-destroy" --config=cloudbuild.yaml .

init:
	@gcloud builds submit --substitutions=_BUILDSTATE="prep" --config=cloudbuild.yaml .

output:
	@gcloud builds submit --substitutions=_BUILDSTATE="tf-output" --config=cloudbuild.yaml .


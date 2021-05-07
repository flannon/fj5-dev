.PHONY: build test
PROJECT_NUMBER=$(shell gcloud projects describe $(PROJECT_ID) --format='value(projectNumber)')
BUILD_CONFIG="cloudbuild.yaml"
BUILD_DIR=$(.)

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

test:
		@echo "$(BOLD)Verifying that the GCS Storage bucket $(BUCKET) for remote state exists $(RESET)"
		@echo "$(BOLD)Verifying the PROJECT_ID: $(PROJECT_ID) $(RESET)"
		@echo "$(BOLD)Verifying the PROJECT_NUMBER: $(PROJECT_NUMBER) $(RESET)"

build:
		@gcloud builds submit --config=${BUILD_CONFIG} ${BUILD_DIR}

## ------------------------------------------------------------
##   BACKEND BLOCK
## ------------------------------------------------------------
terraform {
  backend "gcs" {
    bucket = "tf-fj5-dev-8a00"
    prefix = "/gke-lb"
    credentials = "account.json"
  }
}

# ------------------------------------------------------------
#   PROVIDER BLOCK
# ------------------------------------------------------------

provider "google" {
  credentials = file(var.credentials_path)
  version = "~> 3.65.0"
}

provider "google-beta" {
  credentials = file(var.credentials_path)
  version = "~> 3.65.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

// ------------------------------------------------------------
//   TERRAFORM REMOTE STATE
// ------------------------------------------------------------
data "terraform_remote_state" "gke-lb" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/gke-lb"
  }
}

data "terraform_remote_state" "project" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/project"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/vpc"
  }
}


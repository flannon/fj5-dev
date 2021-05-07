## ------------------------------------------------------------
##   BACKEND BLOCK
## ------------------------------------------------------------
terraform {
  backend "gcs" {
    bucket = "tf-fj5-dev-7fb1"
    prefix = "/project"
    credentials = "./account.json"
  }
}

# ------------------------------------------------------------
#   PROVIDER BLOCK
# ------------------------------------------------------------

provider "google" {
  credentials = file(var.credentials_path)
  version = "~> 3.38.0"
}

provider "google-beta" {
  credentials = file(var.credentials_path)
  version = "~> 3.38.0"
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
data "terraform_remote_state" "project" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/project"
  }
}


data "google_project" "project" {
  project_id = "fj5-dev-7fb1"
}


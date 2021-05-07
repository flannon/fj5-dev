// ------------------------------------------------------------
//   BACKEND BLOCK
// ------------------------------------------------------------
terraform {
  backend "gcs" {
    bucket = "tf-fj5-dev-7fb1"
    prefix = "/iam"
    credentials = "./account.json"
  }
}

// ------------------------------------------------------------
//   PROVIDER BLOCK
// ------------------------------------------------------------
provider "google" {
  credentials = file(var.credentials_path)
  version     = "3.38.0"
}

provider "google-beta" {
  credentials = file(var.credentials_path)
  version     = "3.38.0"
}

provider "null" {
  version = "~> 2.1"
}

locals {
  project_home = var.project_home
  this_service = "iam"
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

data "terraform_remote_state" "iam" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/iam"
  }
}

locals {
  svc_acct = "tf-project"
  svc_acct_email = "google_service_account.${local.svc_acct}.email"
  project_id = data.terraform_remote_state.project.outputs.project_id
  svc_acct_def = "serviceAccount:${local.svc_acct_email}"
}

resource "google_service_account" "tf_project" {
  account_id   = local.svc_acct
  display_name = local.svc_acct
  project      = local.project_id
}

module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 5.1.0"
  projects = ["${data.terraform_remote_state.project.outputs.project_id}"]
  mode     = "additive"

  bindings = {
    "roles/owner" = [
      "${local.svc_acct_def}",
      ]
  }
}

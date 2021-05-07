variable remote_state_bucket_name {
  type = string
  default = "tf-fj5-dev-8a00"
  description = "terraform state backend bucket"
}

variable credentials_path {
  type        = string
  default     = "./account.json"
  description = "Location of the credential file."
}

variable labels {
  description = "Map of labels for project."
  default = {
    "environment" = ""
    "managed_by"  = "terraform"
    "project"     = "fj5-dev"
  }
}

variable project_home {
  description = "URI for the terraform state file"
  default = ".."
  type = string
}

variable service {
  description = "Then name og the GCP service instantiated by the module"
}

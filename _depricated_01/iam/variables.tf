variable credentials_path {
  type        = string
  default     = "./account.json"
  description = "Path to the .json file."
}

variable description {
  default = "Terraform-Deployed."
}

variable project_home {
  type        = string
  default     = ".."
  description = "URI for the terraform state file"
}

variable project_name {
  type        = string
  default     = "fj5-dev"
  description = "URI for the terraform state file"
}

variable project_number {
  type        = string
  default     = "864160298975"
  description = "URI for the terraform state file"
}
variable remote_state_bucket_name {
  type = string
  default = "tf-fj5-dev-7fb1"
  description = "terraform state backend bucket"
}

variable service {
  type = string
  description = "The GCP service amnaged by this module"
}

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

variable activate_apis {
  type = list
  default = [
    "compute.googleapis.com",
  ]
  description = "The list of apis to activate within the project	"
}

variable disable_dependent_services {
  type = bool
  default = true
  description = "Whether services that are enabled and which depend on this service should also be d    isabled when this service is destroyed."
}

#variable environment {
#  type = string
#  description = "The ID of a folder hosting this project"
#}

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

variable project_name {
  description = "Name of the project."
  default     = "fj5-dev"
}

variable project_number {
  description = "Name of the project."
  default     = "39409190445"
}

variable region {
  description = "Default region"
}

variable service {
  description = "Then name og the GCP service instantiated by the module"
}

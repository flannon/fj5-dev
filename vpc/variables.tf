variable credentials_path {
  type    = string
  default = "./account.json"
}

variable remote_state_bucket_name {
  type        = string
  default     = "tf-fj5-dev-8a00"
}

variable service {
  type        = string
  default     = "vpc"
  description = "The GCP service managed by this module"
}

variable network_suffix {
  description = "Name of the VPC."
}

variable project_home {
  description = "URI for the terraform state file"
  type = string
}

variable routing_mode {
  description = "Routing mode. GLOBAL or REGIONAL"
  default     = "GLOBAL"
}

variable subnet_name {
  description = "Name of the subnet."
}

variable subnet_ip {
  description = "Subnet IP CIDR."
}

variable subnet_region {
  description = "Region subnet lives in."
}

variable subnet_private_access {
  default = "true"
}

variable subnet_flow_logs {
  default = "true"
}

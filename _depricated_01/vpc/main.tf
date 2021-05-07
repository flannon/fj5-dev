// ------------------------------------------------------------
//   BACKEND BLOCK
// ------------------------------------------------------------
// Values for the terraform block are provided by the Makefile
terraform {
  backend "gcs" {
    bucket = "tf-fj5-dev-7fb1"
    prefix = "/vpc"
    credentials = "./account.json"
  }
}

// ------------------------------------------------------------
//   PROVIDER BLOCK
// ------------------------------------------------------------

provider "google" {
  credentials = file(var.credentials_path)
  version     = "~> 3.38.0"
}

provider "google-beta" {
  credentials = file(var.credentials_path)
  version     = "~> 3.38.0"
}

provider "null" {
  version = "~> 2.1"
}

// ------------------------------------------------------------
//   TERRAFORM REMOTE STATE
// ------------------------------------------------------------
locals {
  project_home = var.project_home
  this_service      = "vpc"
}

data "terraform_remote_state" "project" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/project"
  }
}

data "terraform_remote_state" "compute" {
  backend = "gcs"
  config = {
    bucket      = var.remote_state_bucket_name
    credentials = var.credentials_path
    prefix      = "/compute"
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

////
// local definitions
////
locals {
  region                 = data.terraform_remote_state.project.outputs.project_default_region
  subnet_01              = "${data.terraform_remote_state.project.outputs.project_name}-subnet-01"
  subnet_01_ip           = "192.168.1.0/24"
  subnet_01_secondary_ip = "192.168.2.0/24"
  subnet_01_description  = "ssh access"
  subnet_02              = "${data.terraform_remote_state.project.outputs.project_name}-subnet-02"
  subnet_02_ip           = "10.10.20.0/24"
  subnet_02_description  = "Subnet description"
  subnet_03              = "${data.terraform_remote_state.project.outputs.project_name}-subnet-03"
  subnet_03_ip           = "10.10.30.0/24"
  subnet_03_description  = "Subnet description"
  subnet_03_region       = data.terraform_remote_state.project.outputs.project_default_region

  router_name = "${module.vpc.network_name}-router"
  #network     = data.terraform_remote_state.vpc.outputs.network_self_link
  #network     = module.vpc.outputs.network_self_link
  project_id  = data.terraform_remote_state.project.outputs.project_id
}
# ------------------------------------------------------------
#   MAIN BLOCK
# ------------------------------------------------------------

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"

  project_id   = data.terraform_remote_state.project.outputs.project_id
  network_name = "${data.terraform_remote_state.project.outputs.project_name}-${var.network_suffix}"
  routing_mode = var.routing_mode
  delete_default_internet_gateway_routes = false

  subnets = [
    {
      subnet_name           = local.subnet_01
      subnet_ip             = local.subnet_01_ip
      subnet_region         = data.terraform_remote_state.project.outputs.project_default_region
      subnet_private_access = true
      subnet_flow_logs      = var.subnet_flow_logs
      description           = local.subnet_01_description
    },
    {
      subnet_name           = local.subnet_02
      subnet_ip             = local.subnet_02_ip
      subnet_region         = data.terraform_remote_state.project.outputs.project_default_region
      subnet_private_access = true
      subnet_flow_logs      = var.subnet_flow_logs
      description           = local.subnet_02_description
    },
    {
      subnet_name               = local.subnet_03
      subnet_ip                 = local.subnet_03_ip
      subnet_region             = data.terraform_remote_state.project.outputs.project_default_region
      subnet_private_access     = true
      subnet_flow_logs          = var.subnet_flow_logs
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    },
  ]

  secondary_ranges = {
      subnet_01 = [
          {
              range_name    = "subnet_01_secondary_ip"
              ip_cidr_range = local.subnet_01_secondary_ip
          },
      ]

      subnet_02 = []
      subnet_03 = []
  }

  routes = [
    {
      name              = "tf-egress-internet"
      description       = "route through the IGW to access the internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = true
    },
    // Example route to instance proxy
    //{
    //  name = "app-proxy"
    //  description = "route through proxy to reach app"
    //  destination_range = local.subnet_01_ip
    //  tags              = "app-proxy"
    //  next_hop_instance = "app-proxy-instance"
    //  next_hop_instance_zone = "${local.subnet_03_region}-a"
    //},
  ]
}

locals {
  loadbalancer_addresses = ["130.211.0.0/22","35.191.0.0/16"]
  iap_addresses          = ["35.235.240.0/20"]

  allow-ingress-iap = {
    description          = "Allow ssh INGRESS"
    direction            = "INGRESS"
    action               = "allow"
    ranges               = local.iap_addresses
    use_service_accounts = false # if `true` targets/sources expect list of instances SA, if false - list of tags
    targets              = null  # target_service_accounts or target_tags depends on `use_service_accounts` value
    sources              = null  # source_service_accounts or source_tags depends on `use_service_accounts` value
    rules = [{
     protocol = "tcp"
      ports    = null
      },
      {
        protocol = "udp"
        ports    = null
    }]
    extra_attributes = {
      disabled = false
      priority = 95
    }
  } // !- allow-ingress-iap

  allow-ingress-iap-ssh = {
    description          = "Allow ssh INGRESS"
    direction            = "INGRESS"
    action               = "allow"
    ranges               = local.iap_addresses
    use_service_accounts = false # if `true` targets/sources expect list of instances SA, if false - list of tags
    targets              = null  # target_service_accounts or target_tags depends on `use_service_accounts` value
    sources              = null  # source_service_accounts or source_tags depends on `use_service_accounts` value
    rules = [{
      protocol = "tcp"
      ports    = ["22"]
      },
      {
        protocol = "udp"
        ports    = null
    }]

    extra_attributes = {
      disabled = false
      priority = 95
    }
  } // !- allow-ingress-iap-ssh

  allow-ingress-80-443-8080 = {
    description          = "Allow all INGRESS to port 6534-6566"
    direction            = "INGRESS"
    action               = "allow"
    ranges               = local.loadbalancer_addresses # source or destination ranges (depends on `direction`)
    use_service_accounts = false # if `true` targets/sources expect list of instances SA, if false - list of tags
    targets              = null  # target_service_accounts or target_tags depends on `use_service_accounts` value
    sources              = null  # source_service_accounts or source_tags depends on `use_service_accounts` value
    rules = [{
      protocol = "tcp"
      ports    = ["80","443","8080"]
      },
      {
        protocol = "udp"
        ports    = null
    }]
    extra_attributes = {
      disabled = false
      priority = 95
    },
  } // !- allow-ingress-80-443-8080
} // !- locals


module "firewall-submodule" {
  source  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version = "~> 2.5"

  project_id              = data.terraform_remote_state.project.outputs.project_id
  network                 = module.vpc.network_name
  internal_ranges_enabled = true
  internal_ranges         = module.vpc.subnets_ips

  internal_allow = [
    {
      protocol = "icmp"
    },
    {
      protocol = "tcp",
      # all ports open if 'ports' key isn't specified
    },
    {
      protocol = "udp"
      # all ports open if 'ports' key isn't specified
    },
  ]
  #custom_rules = local.custom_rules
  custom_rules = {
    #allow-ingress-22          = local.allow-ingress-22
    allow-ingress-iap-ssh     = local.allow-ingress-iap-ssh
    allow-ingress-80-443-8080 = local.allow-ingress-80-443-8080
  }
}


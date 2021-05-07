//
// VPC Outputs
//

output network_name {
  value = module.vpc.network_name
}

output network_self_name {
  value = module.vpc.network_name
}

output network_self_link {
  value = module.vpc.network_self_link
}

output route_names {
  value = module.vpc.route_names
}

output subnets_flow_logs {
  value = module.vpc.subnets_flow_logs
}

output subnets_ips {
  value = module.vpc.subnets_ips
}

output subnets_names {
  value = module.vpc.subnets_names
}

output subnets_private_access {
  value = module.vpc.subnets_private_access
}

output subnets_regions {
  value = module.vpc.subnets_regions
}

output subnets_self_links {
  value = module.vpc.subnets_self_links
}

output subnetworks_self_links {
  value = module.vpc.subnets_self_links
}

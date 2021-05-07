output credentials_path {
  value = var.credentials_path
}

output prefix {
  value = "/"
}

output project_default_region {
  value = var.region
}

output project_id {
  value = data.google_project.project.project_id
}

output project_labels {
  value = var.labels
}

output project_name {
  value = var.project_name
}

output project_number {
  value = var.project_number
}

output remote_state_bucket_name {
  value = var.remote_state_bucket_name
}

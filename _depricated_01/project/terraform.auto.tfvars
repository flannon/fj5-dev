credentials_path = "./account.json"

project_home = ".."

service = "project"

activate_apis = [
    "compute.googleapis.com",          // Required
    "billingbudgets.googleapis.com",   // Required
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "stackdriver.googleapis.com",
]

disable_dependent_services = true

labels = {
    "environment"   = ""
    "group"         = ""
    "managed_by"    = "terraform"
    "project_name"  = "fj5-dev"
}

region = "us-central1"

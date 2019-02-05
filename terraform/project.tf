resource "random_id" "project_id" {
  byte_length = 4
  prefix      = "${var.stack_name}-"
}

resource "google_project" "main" {
  name            = "${var.stack_name}"
  billing_account = "${var.billing_account_id}"
  project_id      = "${random_id.project_id.hex}"
}

resource "google_project_services" "main" {
  project = "${google_project.main.project_id}"

  services = [
    # Not sure if / why we need these but GCP seems to insist on enabling them itself
    # so listing them here to avoid fighting it
    "bigquery-json.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",

    # Makes sense to need these
    "compute.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

locals {
  // Kludge to force dependency order: project > services > everything else
  // (everything else should reference this local)
  // Changing to the terraform-google-modules/project-factory/google module should remove need for this
  project_id = "${google_project_services.main.id}"
}

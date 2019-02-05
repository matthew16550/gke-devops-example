terraform {
  required_version = ">= 0.11.11" // older might be ok, this is just the version I used
}

provider "google" {
  version = "~> 1.20"
  region = "${var.region}"
}

provider "google-beta" {
  version = "~> 1.20"
  region = "${var.region}"
}

provider "kubernetes" {
  version = "~> 1.5"

  client_certificate     = "${base64decode(google_container_cluster.main.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.main.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.main.master_auth.0.cluster_ca_certificate)}"
  host                   = "https://${google_container_cluster.main.endpoint}"
  load_config_file       = false
  password               = "${google_container_cluster.main.master_auth.0.password}"
  username               = "${google_container_cluster.main.master_auth.0.username}"
}

provider "null" {
  version = "~> 2.0"
}

provider "random" {
  version = "~> 2.0"
}

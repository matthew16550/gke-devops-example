// TODO think more whether doing passwords this way is a good idea
resource "random_string" "cluster_password" {
  length = 256
}

resource "google_container_cluster" "main" {
  provider = "google-beta"
  project  = "${local.project_id}"

  name             = "${var.stack_name}"
  region           = "${var.region}"
  additional_zones = ["${var.zones}"]

  master_auth {
    username = "master"
    password = "${random_string.cluster_password.result}"
  }

  remove_default_node_pool = true

  node_pool {
    // this pool cannot be changed without recreating the cluster so use google_container_node_pool.main instead
    name       = "default-pool"
    node_count = 0
  }

  lifecycle {
    "ignore_changes" = [
      "network",    // TODO pass in a network as TF keeps changing "projects/PROJECT_ID/global/networks/default" => "default"
      "node_pool",  // TODO not sure about ignoring this
    ]
  }
}

resource "google_container_node_pool" "main" {
  provider = "google-beta"
  project  = "${local.project_id}"

  cluster = "${google_container_cluster.main.name}"

  // TODO autoscaling is probably more robust than this but when I try it doesnt autoscale above zero!
  node_count = 3

  region = "${var.region}"

  // TODO staying below 1.11.* for now to avoid wierd network bugs that I havent dug into (https://issuetracker.google.com/issues/119820482)
  version = "1.10.12-gke.1"

  management {
    auto_repair  = true
    auto_upgrade = false // TODO probably better if this is true but see comment on "version" above
  }

  node_config {
    disk_size_gb = "10"       // Thats the smallest allowed, expect we dont even need that
    machine_type = "f1-micro" // because its free!

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

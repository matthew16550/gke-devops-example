output "console_for_cluster" {
  value = "https://console.cloud.google.com/kubernetes/clusters/details/${google_container_cluster.main.zone}/${google_container_cluster.main.id}?project=${local.project_id}"
}

output "console_for_container_registry" {
  value = "https://console.cloud.google.com/gcr/images/${local.project_id}"
}

output "console_for_hello_service" {
  value = "https://console.cloud.google.com/kubernetes/service/${var.region}/${google_container_cluster.main.name}/${kubernetes_service.hello.id}?project=${local.project_id}"
}

output "console_for_monitoring" {
  value = "https://app.google.stackdriver.com/?project=${local.project_id}"
}

output "console_for_project" {
  value = "https://console.cloud.google.com/home/dashboard?project=${local.project_id}"
}

output "hello_image" {
  value = "${local.hello_image}"
}

output "hello_url" {
  value = "http://${local.hello_ip}"
}

output "project_id" {
  value = "${local.project_id}"
}

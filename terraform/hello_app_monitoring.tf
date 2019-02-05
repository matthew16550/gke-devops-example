//
// This file (work in progress) configures monitoring & alerting on the Hello app
//

resource "google_monitoring_uptime_check_config" "hello" {
  project      = "${local.project_id}"
  display_name = "Hello Uptime Check"
  timeout      = "5s"
  period       = "60s"

  monitored_resource {
    type = "uptime_url"

    labels = {
      project_id = "${local.project_id}"
      host       = "${local.hello_ip}"
    }
  }

  http_check {
    path = "/"
    port = "80"
  }

  content_matchers = {
    content = "Hello World"
  }
}

resource "google_monitoring_notification_channel" "hello" {
  project      = "${local.project_id}"
  display_name = "Hello Service Notification Channel"
  type         = "email"

  labels = {
    email_address = "${var.monitoring_email_address}"
  }
}

// TODO
//resource "google_monitoring_alert_policy" "hello" {
//  project = "${local.project_id}"
//  enabled = true
//  display_name = "Hello Service Alert"
//  combiner = "OR"
//  "conditions" {
//    display_name = "Uptime"
//    condition_threshold {
//      comparison = ""
//      duration = ""
//    }
//  }
//}

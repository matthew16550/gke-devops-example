//
// This file deploys the "Hello" python web app on Kubernetes
//

locals {
  hello_container_port = 5002

  hello_image = "gcr.io/${local.project_id}/hello"

  hello_ip = "${kubernetes_service.hello.load_balancer_ingress.0.ip}"

  hello_url = "http://${local.hello_ip}"
}

// Just for bootstrapping the stack.  Use bin/image-* scripts to update image after the stack has been created.
// TODO feels too tightly coupled and / or too loosely coupled ?  Adding version numbers should make it more clear.
resource "null_resource" "hello_image" {
  provisioner "local-exec" {
    command = "docker build -t ${local.hello_image} . && docker push ${local.hello_image}"
  }
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name = "hello"
  }

  spec {
    replicas = "${length(var.zones) * 3}"

    selector {
      match_labels {
        app = "hello"
      }
    }

    template {
      metadata {
        labels {
          app = "hello"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
        }

        container {
          image = "${local.hello_image}"
          name  = "hello"

          liveness_probe {
            http_get {
              path = "/"
              port = "${local.hello_container_port}"
            }

            failure_threshold     = 3
            initial_delay_seconds = 5
            period_seconds        = 5
            success_threshold     = 1
            timeout_seconds       = 3
          }

          port {
            container_port = "${local.hello_container_port}"
          }

          resources {
            limits {
              cpu    = "0.2"
              memory = "50Mi"
            }
          }

          security_context {
            read_only_root_filesystem = true
            run_as_user               = 1000
          }
        }
      }
    }
  }

  depends_on = [
    "null_resource.hello_image",
  ]
}

resource "kubernetes_service" "hello" {
  metadata {
    name = "hello"
  }

  spec {
    type = "LoadBalancer"

    selector {
      app = "${kubernetes_deployment.hello.spec.0.template.0.metadata.0.labels.app}"
    }

    port {
      port        = 80
      target_port = "${local.hello_container_port}"
    }
  }
}

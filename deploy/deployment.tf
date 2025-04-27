resource "kubernetes_deployment" "helloworld-dart" {
  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
    labels = {
      app         = "helloworld-dart"
      environment = "production"
      tenant      = "willianpaixao"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "helloworld-dart"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
    }

    template {
      metadata {
        labels = {
          app         = "helloworld-dart"
          environment = "production"
          tenant      = "willianpaixao"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 101
          fs_group        = 101
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        automount_service_account_token = false

        container {
          name              = "helloworld-dart"
          image             = "ghcr.io/willianpaixao/helloworld-dart:1.0.0"
          image_pull_policy = "Always"

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }

          resources {
            limits = {
              cpu    = "50m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          volume_mount {
            name       = "nginx-cache"
            mount_path = "/var/cache/nginx"
          }
          volume_mount {
            name       = "nginx-pid"
            mount_path = "/var/run"
          }
        }

        volume {
          name = "nginx-cache"
          empty_dir {}
        }
        volume {
          name = "nginx-pid"
          empty_dir {}
        }

        termination_grace_period_seconds = 30
      }
    }
  }
}

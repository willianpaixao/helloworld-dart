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
        service_account_name = kubernetes_service_account.helloworld-dart.metadata[0].name

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

resource "kubernetes_resource_quota" "tenant_quotas" {

  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
  }

  spec {
    hard = {
      "requests.cpu"    = "1"
      "requests.memory" = "128Mi"
      "limits.cpu"      = "2"
      "limits.memory"   = "128Mi"
      "pods"            = "10"
    }
  }
}

resource "kubernetes_network_policy" "tenant_isolation" {

  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "name" = "helloworld-dart"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}
resource "kubernetes_network_policy" "helloworld-dart" {
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
    pod_selector {
      match_labels = {
        app = "helloworld-dart"
      }
    }

    policy_types = ["Ingress", "Egress"]

    # Allow incoming traffic only from the ingress controller
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }

      ports {
        port     = 80
        protocol = "TCP"
      }
    }

    # Allow outbound DNS traffic
    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
        pod_selector {
          match_labels = {
            "k8s-app" = "kube-dns"
          }
        }
      }

      ports {
        port     = 53
        protocol = "UDP"
      }
      ports {
        port     = 53
        protocol = "TCP"
      }
    }

    # Deny all other traffic
  }
}
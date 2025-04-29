resource "kubernetes_ingress_v1" "helloworld-dart" {
  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
    labels = {
      app         = "helloworld-dart"
      environment = "production"
      tenant      = "willianpaixao"
    }
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "helloworld-dart.example.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "helloworld-dart"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
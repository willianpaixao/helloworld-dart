resource "kubernetes_service_account" "helloworld-dart" {
  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
    labels = {
      app         = "helloworld-dart"
      environment = "production"
      tenant      = "willianpaixao"
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_role" "helloworld-dart" {
  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
    labels = {
      app         = "helloworld-dart"
      environment = "production"
      tenant      = "willianpaixao"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list"]
  }

  # Add other permissions if needed, but following least privilege principle
}

resource "kubernetes_role_binding" "helloworld-dart" {
  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
    labels = {
      app         = "helloworld-dart"
      environment = "production"
      tenant      = "willianpaixao"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.helloworld-dart.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.helloworld-dart.metadata[0].name
    namespace = "helloworld-dart"
  }
}
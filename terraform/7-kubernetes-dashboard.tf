resource "helm_release" "kubernetes-dashboard" {
  name = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true
  version          = "6.0.8"
  values = [file("values/kubernetes-dashboard.yaml")]
  depends_on = [
    helm_release.metrics-server
  ]
}

resource "kubernetes_manifest" "kubernetes-dashboard-sa" {
  manifest = yamldecode(file("manifests/kubernetes-dashboard/admin-sa.yaml"))
  depends_on = [
    helm_release.kubernetes-dashboard
  ]
}
resource "kubernetes_manifest" "kubernetes-dashboard-cluster-role" {
  manifest = yamldecode(file("manifests/kubernetes-dashboard/admin-cluster-role.yaml"))
  depends_on = [
    kubernetes_manifest.kubernetes-dashboard-sa
  ]
}
resource "kubernetes_manifest" "kubernetes-dashboard-user" {
  manifest = yamldecode(file("manifests/kubernetes-dashboard/admin-user-secret.yaml"))
  depends_on = [
    kubernetes_manifest.kubernetes-dashboard-sa
  ]
}

# kubectl -n kubernetes-dashboard get secret admin-user -o jsonpath={".data.token"} | base64 -d
# kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 8443:443
# firefox https://localhost:8443

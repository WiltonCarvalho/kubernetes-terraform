resource "helm_release" "tempo" {
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  namespace        = "tempo"
  create_namespace = true
  version          = "1.6.3"
  values           = [file("values/tempo.yaml")]
  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

resource "kubernetes_namespace" "otel" {
  metadata {
    name = "otel"
  }
}
resource "kubernetes_manifest" "otel-collector-cm" {
  manifest = yamldecode(file("manifests/otel/otel-collector-cm.yaml"))
  depends_on = [
    kubernetes_namespace.otel
  ]
}
resource "kubernetes_manifest" "otel-collector-deploy" {
  manifest = yamldecode(file("manifests/otel/otel-collector-deploy.yaml"))
  depends_on = [
    kubernetes_namespace.otel,
    helm_release.tempo
  ]
}
resource "kubernetes_manifest" "otel-collector-svc" {
  manifest = yamldecode(file("manifests/otel/otel-collector-svc.yaml"))
  depends_on = [
    kubernetes_namespace.otel
  ]
}

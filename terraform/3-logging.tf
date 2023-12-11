resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "loki"
  create_namespace = true
  version          = "5.39.0"
  values           = [file("values/loki.yaml")]
  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

resource "helm_release" "promtail" {
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = "promtail"
  create_namespace = true
  version          = "6.15.3"
  values           = [file("values/promtail.yaml")]
  depends_on = [
    helm_release.loki
  ]
}
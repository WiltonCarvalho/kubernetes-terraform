/*
kubectl create ns monitoring

(
  cd /tmp
  echo > .rnd
  openssl req -new -nodes -x509 -subj '/O=TestCert/CN=172.19.0.1.sslip.io' \
    -days 3650 -keyout test-cert.key -out test-cert.crt -extensions v3_ca
)

kubectl -n monitoring create secret tls test-cert-2023 \
  --key "/tmp/test-cert.key" \
  --cert "/tmp/test-cert.crt"

kubectl -n monitoring create secret generic grafana-admin \
  --from-literal=user=admin \
  --from-literal=password=xxxxxxxxxxxxx
*/


data "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

data "kubernetes_secret" "grafana-cert" {
  metadata {
    name = "test-cert-2023"
  }
}
data "kubernetes_secret" "grafana-admin" {
  metadata {
    name = "grafana-admin"
  }
}

resource "helm_release" "metrics-server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server"
  chart            = "metrics-server"
  namespace        = "monitoring"
  create_namespace = false
  version          = "3.11.0"
  values           = [file("values/metrics-server.yaml")]
  depends_on = [
    data.kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "kube-prometheus-stack" {
  name = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "55.0.0"
  namespace        = "monitoring"
  create_namespace = false
  values = [file("values/kube-prometheus-stack.yaml")]
  depends_on = [
    data.kubernetes_namespace.monitoring,
    data.kubernetes_secret.grafana-cert,
    data.kubernetes_secret.grafana-admin,
    helm_release.ingress-nginx-private,
    helm_release.metrics-server
  ]
}

resource "helm_release" "prometheus-adapter" {
  name             = "prometheus-adapter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-adapter"
  version          = "4.9.0"
  namespace        = "monitoring"
  create_namespace = false
  values           = [file("values/prometheus-adapter.yaml")]
  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

resource "null_resource" "dashboards" {
  provisioner "local-exec" {
    command = "kubectl apply -k dashboards"
  }
  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

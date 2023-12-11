/*
kubectl create ns argocd

(
  cd /tmp
  echo > .rnd
  openssl req -new -nodes -x509 -subj '/O=TestCert/CN=172.19.0.1.sslip.io' \
    -days 3650 -keyout test-cert.key -out test-cert.crt -extensions v3_ca
)

kubectl -n argocd create secret tls test-cert-2023 \
  --key "/tmp/test-cert.key" \
  --cert "/tmp/test-cert.crt"
*/

data "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
data "kubernetes_secret" "argocd-cert" {
  metadata {
    name = "test-cert-2023"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.51.6"
  values           = [file("values/argocd.yaml")]
  depends_on = [
    data.kubernetes_namespace.argocd,
    data.kubernetes_secret.argocd-cert,
    helm_release.ingress-nginx-private,
    helm_release.kube-prometheus-stack
  ]
}


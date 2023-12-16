### Test Docker ###
```
docker info
```

### Setup KinD ###
```
kind create cluster --image kindest/node:v1.26.2 --config kind-config.yaml
```

### MetalLB ###
```
(
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
  kubectl -n metallb-system get pod --watch
)
```

### Setup address pool used by loadbalancers ###
```
(
  docker network inspect kind | jq -r '.[].IPAM.Config[0].Subnet'
  kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/metallb-config.yaml
  kubectl -n metallb-system get ipaddresspools
)
```

### Namespaces ###
```
(
  kubectl create ns monitoring
  kubectl create ns argocd
)
```

### Test Ingress Cert ###
```
(
  cd /tmp
  echo > .rnd
  openssl req -new -nodes -x509 -subj '/O=TestCert/CN=172.19.255.250.sslip.io' \
    -days 3650 -keyout test-cert.key -out test-cert.crt -extensions v3_ca \
    2> /dev/null
  openssl verify -CAfile /tmp/test-cert.crt /tmp/test-cert.crt
)
```

### ArgoCD Ingress Cert ###
```
(
  kubectl -n argocd create secret tls test-cert-2023 \
    --key "/tmp/test-cert.key" \
    --cert "/tmp/test-cert.crt"
)
```

### Grafana Ingress Cert ###
```
(
  kubectl -n monitoring create secret tls test-cert-2023 \
    --key "/tmp/test-cert.key" \
    --cert "/tmp/test-cert.crt"
)
```

### Grafana Admin Password ###
```
(
  kubectl -n monitoring create secret generic grafana-admin \
    --from-literal=user=admin \
    --from-literal=password=xxxxxxxxxxxxx
)
```

### Terraform ###
```
cd terraform
rm -rf terraform.tfstate* .terraform*
```

```
terraform init
terraform apply --auto-approve
```
```
watch -n 3 "kubectl get pod -A | grep -v kube-system"
```

### Prometheus Port Forward ###
```
kubectl -n monitoring port-forward services/prometheus-operated 9090:9090
```

### Prometheus ###
```
firefox localhost:9090
```

### Grafana Ingress ###
```
firefox https://172.19.255.250.sslip.io/grafana
```

### ArgoCD Admin Token ###
```
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### ArgoCD Ingress ###
```
firefox https://172.19.255.250.sslip.io/argocd
```

### Kubernetes Dashboard Token ###
```
kubectl -n kubernetes-dashboard get secret admin-user \
  -o jsonpath={".data.token"} | base64 -d
```

### Kubernetes Dashboard Port Forward ###
```
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 8443:443
```

### Kubernetes Dashboard ###
```
firefox https://localhost:8443
```
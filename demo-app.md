# Build
```
docker build -t demo-app demo-app/ --progress=plain
```

# Run Demo App
```
docker run -d --rm --name demo-app -p 8080:8080 -p 8081:8081 demo-app
docker logs demo-app

curl -f localhost:8080
curl -f localhost:8081/actuator/health

docker stop demo-app
```

# KinD Local Registry
```
kubectl apply -f registry/registry.yaml
```

# Port Forward Local Registry
```
kubectl port-forward deployment/registry 32000:5000
```

# Push Demo App to KinD Registry
```
docker tag demo-app:latest localhost:32000/demo-app:latest
docker push localhost:32000/demo-app:latest
```

# Deploy Demo App
```
kubectl apply -f deployment-javaagent.yaml
kubectl logs deployments/demo-app -f
```

# Test
```
curl -fsSL demo-app.172.19.255.250.sslip.io

firefox https://172.19.255.250.sslip.io/grafana
```

# deploy k8s resources

```
# create namespace
kubectl apply -f namespaces.yaml

# apply cluster role and rolebinding for application insights
kubectl apply -f k8s-rbac-ai.yaml


```
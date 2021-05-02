# deploy k8s resources

## setup environment for this application
```
# create namespace
kubectl apply -f namespaces.yaml0

# apply cluster role and rolebinding for application insights
kubectl apply -f k8s-rbac-ai.yaml

```

## setup pod identity

At first, you should assign some roles.
`ri-role-assign-for-podaad.bicep` refers to [Role Assignment in AAD Pod Identity](https://azure.github.io/aad-pod-identity/docs/getting-started/role-assignment/). Please check latest version of requrement if you want.

```
az deployment group create -f ri-role-assign-for-podaad.bicep --resource-group ${RESOURCE_GROUP} 
```

Then you should install aad-pod-identity to your cluster.

```
# 
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts

helm install aad-pod-identity aad-pod-identity/aad-pod-identity
```
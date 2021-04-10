# Help for deploying azure resources

```
export RESOURCE_GROUP=<put your resource group name(default ri-app-rg)>

# enable pod identity feature (because the feature is still beta yet)
az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
az deployment group create -f ri-aks.bicep --resource-group ${RESOURCE_GROUP}

az deployment group create -f ri-insights.bicep --resource-group ${RESOURCE_GROUP} --parameters parameters.json

az deployment group create -f ri-delivery.bicep --resource-group ${RESOURCE_GROUP} --parameters parameters.json

az deployment group create -f ri-package.bicep --resource-group ${RESOURCE_GROUP} --parameters parameters.json

az deployment group create -f ri-drone.bicep --resource-group ${RESOURCE_GROUP} --parameters parameters.json

az deployment group create -f ri-ingestion.bicep --resource-group ${RESOURCE_GROUP} --parameters parameters.json

```
@description('Application name')
param appName string = 'fabrikam'
@description('location for this resource')
param location string = resourceGroup().location

// settings for ACR
@description('ACR name')
param acrName string = 'acr${appName}'
@description('ACR resource group name')
param acrResourceGroupName string = 'acr-${resourceGroup().name}'
@description('ACR resource group location')
param acrLocation string = resourceGroup().location

// settings for AKS
@description('Kubernetes cluster name')
param aksClusterName string = '${appName}'
@description('Availability zone for aks')
param aksAvailabilityZones array = [
  '1'
  '2'
  '3'
]
@description('Node disk size in GB')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0
@description('The mininum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
param agentMinCount int = 3
@description('The maximum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
param agentMaxCount int = 5

@description('service principal id')
param servicePrincipalId string = ''
@description('service principal secret')
@secure()
param servicePrincipalSecret string = ''

// settings for Log analytics workspace
@description('workspace sku')
param workspaceSku string = 'Free'

var aksClusterVersion = '1.19.7'

module workspace '../templates/workspace.bicep' = {
  name: 'nested-workspace-${appName}'
  params: {
    workspaceNamePrefix: aksClusterName
    sku: workspaceSku
  }
}

module aks '../templates/aks-cluster.bicep' = {
  name: 'nested-aks-${appName}'
  params: {
    clusterName: aksClusterName
    kubernetesVersion: aksClusterVersion
    agentMinCount: agentMinCount
    agentMaxCount: agentMaxCount
    availabilityZones: aksAvailabilityZones
    workspaceId: workspace.outputs.id
    servicePrincipalId: servicePrincipalId
    servicePrincipalSecret: servicePrincipalSecret
  }
}

module acrGroup '../templates/resource-group.bicep' = if(resourceGroup().name != acrResourceGroupName) {
  scope: subscription()
  name: 'neteted-rg-${acrResourceGroupName}'
  params: {
    name: acrResourceGroupName
    location: acrLocation
  }
}

module acr '../templates/acr.bicep' = {
  name: 'neteted-acr-${appName}'
  scope: resourceGroup(acrResourceGroupName)
  params:{
    acrName: acrName
    targetPrincipalId: aks.outputs.principalId
    tags: {
      displayName: 'Container Registory'
      clusterName: aksClusterName
    }
  }
}

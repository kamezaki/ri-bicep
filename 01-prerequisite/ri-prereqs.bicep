// this file can only be deployed at a subscription scope
targetScope = 'subscription'

@description('Resource group name for general purpose')
param resourceGroupName string = 'ri-app-rg'
@description('location for general purpose resource group')
param location string = deployment().location
@description('execution environment')
@allowed([
  'dev'
  'qa'
  'staging'
  'prod'
])
param environment string = 'dev'
param apps array = [
  'workflow'
  'delivery'
  'droneScheduler'
]

module rg '../templates/resource-group.bicep' = {
  name: 'nested-${resourceGroupName}'
  params: {
    name: resourceGroupName
    location: location
    tags: {
      displayName: 'Resource group for general purpose'
    }
  }
} 

var rgScope = resourceGroup(resourceGroupName)
module userIdentities '../templates/user-assingment-identity.bicep' = [for app in apps: {
  scope: rgScope
  name: 'nested-identity-${environment}-${app}'
  dependsOn: [
    rg
  ]
  params: {
    name: '${environment}-${app}'
    tags: {
      what: 'rbac'
      reason: 'aad-pod-identity'
      app: 'fabrikam-${app}'
      environment: environment
    }
  }
}]

output resourceGroupName string = rg.name
output assingedIdentities array = [for (id, i) in apps: {
  appName: id
  idName: userIdentities[i].outputs.idName
  principalId: userIdentities[i].outputs.id
}]

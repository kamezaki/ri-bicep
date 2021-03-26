@description('Container registory name - it should be alphanumeric string')
param acrName string
@description('Location for workspace')
param location string = resourceGroup().location
@description('sku for ACR')
param sku string = 'Basic'
@description('Admin user is enabled')
param adminUserEnabled bool = false
@description('tags for container registory')
param tags object = {}
@description('target princal id for acr pull role')
param targetPrincipalId string

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: sku
  }
  tags: tags
}

var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource roleDef 'Microsoft.Authorization/roleDefinitions@2015-07-01' existing = {
  scope: subscription()
  name: acrPullRole
}

// for acr pull role
resource pull 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acrName, 'AcrPullRole')
  scope: acr
  properties:{
    principalId: targetPrincipalId
    roleDefinitionId: roleDef.id
    principalType: 'ServicePrincipal'
    description: '${acrName}-acrpull'
  }
}


output acrId string = acr.id

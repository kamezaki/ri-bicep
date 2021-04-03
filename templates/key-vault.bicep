@description('tenant id for key vault')
param tenantId string = subscription().tenantId
@description('Key vault name')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('key vault sku')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'
@description('principal id for role assingment')
param rolePrincipalId string = ''
@description('access princal ids')
param principalIds array
@description('{name, value} array data')
param data array = []
@description('set true this is for production')
param production bool = false
@description('tags for resource')
param tags object = {}

var permissions = [
  'get'
  'list'
]


resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties:{
    tenantId: tenantId
    sku:{
      family: 'A'
      name: sku
    }
    createMode: 'default'
    enableSoftDelete: production
    accessPolicies: [ for id in principalIds: {
      tenantId: tenantId
      objectId: id
      permissions: {
          secrets: [
            'get'
            'list'
          ]
      }
    }]
  }
  resource resources 'secrets' = [for item in data: {
    name: item.key
    properties: {
      value: item.value
    }
  }]
  tags: tags
}

var readerRoleObjectId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
module readerRoleDef 'role-definitions.bicep' = {
  name: readerRoleObjectId
  params: {
    roleId: readerRoleObjectId
  }
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(!empty(rolePrincipalId)) {
  name: guid('${name}-role-assign')
  scope: vault
  properties: {
    principalId: rolePrincipalId
    roleDefinitionId: readerRoleDef.outputs.id
  }
}

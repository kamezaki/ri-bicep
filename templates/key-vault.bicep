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

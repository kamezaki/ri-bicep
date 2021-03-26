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
param sku string
@description('tags for resource')
param tags object = {}

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties:{
    tenantId: tenantId
    sku:{
      family: 'A'
      name: sku
    }
  }
}

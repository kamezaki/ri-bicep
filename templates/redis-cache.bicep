@description('redis cache name')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('sku name for redis cache')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'
@description('cache capacity: 1 - 5 for Premium, 0 - 6 for others')
@minValue(0)
@maxValue(6)
param capacity int = sku == 'Premium' ? 1 : 0
@description('tags for redis cache')
param tags object = {}

var skuFamily = sku == 'Premium' ? 'P' : 'C'

resource cache 'Microsoft.Cache/redis@2020-06-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: sku
      family: skuFamily
      capacity: capacity
    }
    
  }
  tags: tags
}

// TODO diagnostics

output id string = cache.id
output primaryKey string = listKeys(cache.id, cache.apiVersion).primaryKey
output hostname string = cache.properties.hostName

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
@description('Storage account name')
param storageAccountName string
@description('enable diagnostics')
param diagnosticsEnabled bool = true
@description('Retension days of diagnostics')
@minValue(1)
@maxValue(730)
param retentionDays int = 7
@description('tags for redis cache')
param tags object = {}

var skuFamily = sku == 'Premium' ? 'P' : 'C'
module sa 'storage-account.bicep' = if(diagnosticsEnabled) {
  name: 'nested-rso-${name}'
  params: {
    name: storageAccountName
    tags: tags
  }
}

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
resource diag 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'redis-diag-${name}'
  scope: cache
  properties: {
    storageAccountId: diagnosticsEnabled ? sa.outputs.id : json('null')
    metrics: [
      {
        timeGrain: 'AllMetrics'
        enabled: diagnosticsEnabled
        retentionPolicy: {
          days: retentionDays
          enabled: diagnosticsEnabled
        }
      }
    ]
  }
}

output id string = cache.id
output primaryKey string = listKeys(cache.id, cache.apiVersion).primaryKey
output hostname string = cache.properties.hostName

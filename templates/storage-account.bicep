@description('storage account name')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('Kind of storage account')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'
@description('Storage account sku name')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
])
param sku string = 'Standard_LRS'
@description('Storage account sku tier')
@allowed([
  'Standard'
  'Premium'
])
param tier string = 'Standard'
@description('tags for storage account')
param tags object = {}

resource sa 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: name
  location: location
  kind: kind
  sku:{
    name: sku
    tier: tier
  }  
}

output id string = sa.id

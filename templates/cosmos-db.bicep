@description('database account name')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('Database kind')
@allowed([
  'GlobalDocumentDB'
  'MongoDB'
  'Parse'
])
param kind string = 'GlobalDocumentDB'
@description('Database account offer type')
param accountOfferType string = 'Standard'
@description('tags for database')
param tags object = {}

resource dbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-03-01-preview' = {
  name: name
  location: location
  kind: kind
  properties: {
    databaseAccountOfferType: accountOfferType
    createMode: 'Default' // TODO To be parameterized
    locations:[
      {
        locationName: location
        failoverPriority: 0
      }
      // TODO TBD
    ]
  }
  tags: tags
}


output id string = dbAccount.id
output documentEndpoint string = dbAccount.properties.documentEndpoint
output primaryMasterKey string = listKeys(dbAccount.id, dbAccount.apiVersion).primaryMasterKey

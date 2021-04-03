@description('setup environment name')
param environment string
@description('Instrumentation Key for Applicatoin Insights')
param instrumentationKey string

@description('tenant id')
param tenantId string = subscription().tenantId
@description('Application name')
param appName string = 'fabrikam'

var diagStoregeName = '${environment}rsto${uniqueString(resourceGroup().id)}'
var cacheName = '${environment}-d-${uniqueString(resourceGroup().id)}'
var dbName = '${environment}-d-${uniqueString(resourceGroup().id)}'
var kvName = '${environment}-d-${uniqueString(resourceGroup().id)}'

// Deploy was failed at 2/Apr/2021
//
// module cache '../templates/redis-cache.bicep' = {
//   name: 'nested-cache-${cacheName}'
//   params: {
//     name: cacheName
//     storageAccountName: diagStoregeName
//     tags: {
//       displayName: 'reds cache inflight delilveries'
//       app: '${appName}-delivery'
//       environment: environment
//     }
//   }
// }

module database '../templates/cosmos-db.bicep' = {
  name: 'nested-db-${dbName}'
  params: {
    name: dbName
    kind: 'GlobalDocumentDB'
    tags: {
      displayName: 'Delivery Cosmos DB'
      app: '${appName}-delivery'
      environment: environment
    }
  }
}

// // todo enable diagnostics

var readerRoleObjectId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

module deliveryPrincipal '../templates/query-identity.bicep' = {
  name: 'query-${environment}-delivery'
  params: {
    name: '${environment}-delivery'
  }
}

module deliveryKV '../templates/key-vault.bicep' = {
  name: 'nested-kv-${kvName}'
  params: {
    name: kvName
    rolePrincipalId: deliveryPrincipal.outputs.principalId
    principalIds: [
      deliveryPrincipal.outputs.principalId
      readerRoleObjectId
    ]
    data: [
      {
        key: 'CosmosDB-Endpoint'
        value: database.outputs.documentEndpoint
      }
      {
        key: 'CosmosDB-Key'
        value: database.outputs.primaryMasterKey
      }
      // {
      //   key: 'RedisCache-Endpoint'
      //   value: cache.outputs.hostname
      // }
      // {
      //   key: 'RedisCache-AccessKey'
      //   value: cache.outputs.primaryKey
      // }
      {
        key: 'ApplicationInsights--InstrumentationKey'
        value: instrumentationKey
      }
    ]
    tags: {
      displayName: 'Delivery Key Vault'
      app: '${appName}-delivery'
      environment: environment
    }
  }
}

// TODO
// add rolw with for aks

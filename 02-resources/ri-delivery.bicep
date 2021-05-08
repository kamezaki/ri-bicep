@description('setup environment name')
param environment string
@description('Application Insights name')
param insightsName string = '${environment}-${uniqueString('ai', resourceGroup().id)}'

@description('tenant id')
param tenantId string = subscription().tenantId
@description('Application name')
param appName string = 'fabrikam'

@description('Kubernetes cluster name')
param aksClusterName string = '${appName}'

var diagStoregeName = '${environment}rsto${uniqueString(resourceGroup().id)}'
var cacheName = '${environment}-d-${uniqueString(resourceGroup().id)}'
var dbName = '${environment}-d-${uniqueString(resourceGroup().id)}'
var kvName = '${environment}-d-${uniqueString(resourceGroup().id)}'

module cache '../templates/redis-cache.bicep' = {
  name: 'nested-cache-${cacheName}'
  params: {
    name: cacheName
    storageAccountName: diagStoregeName
    tags: {
      displayName: 'reds cache inflight delilveries'
      app: '${appName}-delivery'
      environment: environment
    }
  }
}

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

module deliveryPrincipal '../templates/query-identity.bicep' = {
  name: 'query-${environment}-delivery'
  params: {
    name: '${environment}-delivery'
  }
}

module insights '../templates/query-insights.bicep' = {
  name: 'query-${insightsName}'
  params: {
    name: insightsName
  }
}

module deliveryKV '../templates/key-vault.bicep' = {
  name: 'nested-kv-${kvName}'
  params: {
    name: kvName
    rolePrincipalId: deliveryPrincipal.outputs.principalId
    principalIds: [
      deliveryPrincipal.outputs.principalId
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
      {
        key: 'RedisCache-Endpoint'
        value: cache.outputs.hostname
      }
      {
        key: 'RedisCache-AccessKey'
        value: cache.outputs.primaryKey
      }
      {
        key: 'ApplicationInsights--InstrumentationKey'
        value: insights.outputs.instrumentationKey
      }
    ]
    tags: {
      displayName: 'Delivery Key Vault'
      app: '${appName}-delivery'
      environment: environment
    }
  }
}

module bindCluster '../templates/bind-to-aks.bicep' = {
  name: 'nested-bind-cluster-${environment}-delivery'
  params: {
    idName: deliveryPrincipal.outputs.name
    aksClusterName: aksClusterName
  }
}

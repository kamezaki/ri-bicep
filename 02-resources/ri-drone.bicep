@description('setup environment name')
param environment string
@description('Instrumentation Key for Applicatoin Insights')
param instrumentationKey string

@description('Application name')
param appName string = 'fabrikam'

var dbName = '${environment}-ds-${uniqueString(resourceGroup().id)}'
var kvName = '${environment}-ds-${uniqueString(resourceGroup().id)}'

module database '../templates/cosmos-db.bicep' = {
  name: 'nested-db-${dbName}'
  params: {
    name: dbName
    tags: {
      displayName: 'droneSheduler Cosmos DB'
      app: '${appName}-droneScheduler'
      environment: environment
    }
  }
}

module droneSchedulerPrincipal '../templates/query-identity.bicep' = {
  name: 'query-${environment}-droneScheduler'
  params: {
    name: '${environment}-droneScheduler'
  }
}

module droneKV '../templates/key-vault.bicep' = {
  name: 'nested-kv-${kvName}'
  params: {
    name: kvName
    principalIds: [
      droneSchedulerPrincipal.outputs.principalId
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
        key: 'CosmosDBConnectionMode'
        value: 'Gateway'
      }
      {
        key: 'CosmosDBConnectionProtocol'
        value: 'Https'
      }
      {
        key: 'CosmosDBConnectionsLimit'
        value: 50
      }
      {
        key: 'CosmosDBMaxParallelism'
        value: -1
      }
      {
        key: 'CosmosDBMaxBufferedItemCount'
        value: 0
      }
      {
        key: 'FeatureManagement--UsePartitionKey'
        value: false
      }
      {
        key: 'ApplicationInsights--InstrumentationKey'
        value: instrumentationKey
      }
    ]
    tags: {
      displayName: 'DroneScheduler Key Vault'
      app: '${appName}-droneScheduler'
      environment: environment
    }
  }
}

// TODO
// add role assignment
// add rolw with for aks

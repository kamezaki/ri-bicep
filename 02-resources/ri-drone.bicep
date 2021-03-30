@description('setup environment name')
param environment string
@description('Instrumentation Key for Applicatoin Insights')
param instrumentationKey string

@description('Application name')
param appName string = 'fabrikam'

var dbName = '${environment}-ds-${uniqueString(resourceGroup().id)}'

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

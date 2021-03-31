@description('setup environment name')
param environment string
@description('Instrumentation Key for Applicatoin Insights')
param instrumentationKey string

@description('Application name')
param appName string = 'fabrikam'

var ingestionSBNamespace = '${environment}-i-${uniqueString(resourceGroup().id)}'
var ingestionSBName = '${environment}-i-${uniqueString(resourceGroup().id)}'
var ingestionServiceAccessKey = 'ingestionServiceAccessKey'

var workflowServiceAccessKey = 'WorkflowServiceAccessKey'

module sb '../templates/service-bus.bicep' = {
  name: 'nested-${ingestionSBName}'
  params: {
    namespace: ingestionSBNamespace
    name: ingestionSBName
    sendAccessKey: ingestionServiceAccessKey
    listenAccessKey: workflowServiceAccessKey
    tags: {
      displayName: 'Ingestion and Workflow Servie Bus'
      app: '${appName}-ingestion'
      producer: '${appName}-ingestion'
      consumer: '${appName}-workflow'
      environment: environment
    }
  }
}

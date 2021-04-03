@description('setup environment name')
param environment string
@description('Instrumentation Key for Applicatoin Insights')
param instrumentationKey string

@description('Application name')
param appName string = 'fabrikam'

var ingestionSBNamespace = '${environment}-i-${uniqueString(resourceGroup().id)}'
var ingestionSBName = '${environment}-i-${uniqueString(resourceGroup().id)}'
var ingestionServiceAccessKey = 'ingestionServiceAccessKey'

var workflowKVName = '${environment}-wf-${uniqueString(resourceGroup().id)}'
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

module workflowPrincipal '../templates/query-identity.bicep' = {
  name: 'query-${environment}-workflow'
  params: {
    name: '${environment}-workflow'
  }
}

module workflowKV '../templates/key-vault.bicep' = {
  name: 'netsted-kv-${workflowKVName}'
  params: {
    name: workflowKVName
    rolePrincipalId: workflowPrincipal.outputs.principalId
    principalIds: [
      workflowPrincipal.outputs.principalId
    ]
    data: [
      {
        key: 'QueueName'
        value: ingestionSBName
      }
      {
        key: 'QueueEndpoint'
        value: sb.outputs.serviceBusEndpoint
      }
      {
        key: 'QueueAccessPolicyName'
        value: workflowServiceAccessKey
      }
      {
        key: 'QueueAccessPolicyKey'
        value: sb.outputs.sendRuleId
      }
      {
        key: 'ApplicationInsights--InstrumentationKey'
        value: instrumentationKey
      }
    ]
    tags: {
      displayName: 'Workflow Key Vault'
      app: '${appName}-workflow'
      environment: environment
    }
  }
}

// TODO
// add role with for aks

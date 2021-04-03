@description('setup environment name')
param environment string

@description('Name prefix for Application insights')
param tenantId string = subscription().tenantId
@description('Application name')
param appName string = 'fabrikam'
@description('Application Insights name')
param insightsName string = '${environment}-${uniqueString('ai', resourceGroup().id)}'

module insights '../templates/app-insights.bicep' = {
  name: 'nested-${insightsName}'
  params: {
    name: insightsName    
    tags: {
      displayName: 'Application Insights Instance - Distribute Tracing'
      environment: environment
    }
  }
}

output insightsId string = insights.outputs.id
output instrumentationKey string = insights.outputs.instrumentationKey

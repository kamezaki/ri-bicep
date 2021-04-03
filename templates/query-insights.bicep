@description('Application Insights name')
param name string

resource insights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: name
}

output instrumentationKey string = insights.properties.InstrumentationKey

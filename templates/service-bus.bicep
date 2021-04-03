@description('service bus namespace')
param namespace string
@description('service bus name')
param name string
@description('Authrorization access key(send)')
param sendAccessKey string
@description('Authrorization access key(listen)')
param listenAccessKey string
@description('resource location')
param location string = resourceGroup().location
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'
@description('tags for service bus')
param tags object = {}

resource busNamespace 'Microsoft.ServiceBus/namespaces@2018-01-01-preview' = {
  name: namespace
  location: location
  sku: {
    name: sku
  }
  tags: tags
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2018-01-01-preview' = {
  parent: busNamespace
  name: name
  properties: {
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    enablePartitioning: true
  }
}

resource sendRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' = {
  parent: busNamespace
  name: sendAccessKey
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource listenRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' = {
  parent: busNamespace
  name: listenAccessKey
  properties: {
    rights: [
      'Listen'
    ]
  }
}

output serviceBusEndpoint string = busNamespace.properties.serviceBusEndpoint
output sendRuleId string = sendRule.id
output listenRuneId string = listenRule.id

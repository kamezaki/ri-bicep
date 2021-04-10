@description('user assingment identity name')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('tags for resource')
param tags object = {}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
  tags: tags
}

output idName string = userIdentity.name
output id string = userIdentity.id
output clientId string = userIdentity.properties.clientId
output principalId string = userIdentity.properties.principalId

@description('query user identity name')
param name string

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: name
}

output id string = userIdentity.id
output name string = userIdentity.name
output principalId string = userIdentity.properties.principalId

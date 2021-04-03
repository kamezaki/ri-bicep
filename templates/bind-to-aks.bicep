@description('bind user/principal name')
param idName string
@description('bind target cluster name')
param aksClusterName string

var managedIdentityOperatorRoleObjectId = 'f1a07417-d97a-45cb-824c-7a7467783830'
module queryMonitorRole 'role-definitions.bicep' = {
  name: 'query-${managedIdentityOperatorRoleObjectId}'
  params: {
    roleId: managedIdentityOperatorRoleObjectId
  }
}

module cluster 'query-aks.bicep' = {
  name: 'query-${aksClusterName}'
  params: {
    name: aksClusterName
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: idName
}

resource assign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(idName, aksClusterName)
  scope: userIdentity
  properties: {
    principalId: cluster.outputs.principalId
    roleDefinitionId: queryMonitorRole.outputs.id
    principalType: 'ServicePrincipal'
  }
}

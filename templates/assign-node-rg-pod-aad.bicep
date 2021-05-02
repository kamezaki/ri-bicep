@description('principal id of cluster nodes')
param principalId string

// Managed Identity Operator
var managedIdentityOperatorRoleObjectId = 'f1a07417-d97a-45cb-824c-7a7467783830'

module queryManagedIdentityOperatorRole '../templates/role-definitions.bicep' = {
  name: 'query-${managedIdentityOperatorRoleObjectId}'
  params: {
    roleId: managedIdentityOperatorRoleObjectId
  }
}

resource assignManagementIdOperatorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, managedIdentityOperatorRoleObjectId)
  scope: resourceGroup()
  properties:{
    principalId: principalId
    roleDefinitionId: queryManagedIdentityOperatorRole.outputs.id
    principalType: 'ServicePrincipal'
    description: 'for AAD Pod Identity'
  }
}

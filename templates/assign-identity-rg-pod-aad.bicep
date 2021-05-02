@description('principal id of cluster nodes')
param principalId string

// Managed Identity Operator
var managedIdentityOperatorRoleObjectId = 'f1a07417-d97a-45cb-824c-7a7467783830'
// Virtual Machine Contributor
var virtualMachineContributorRoleObjectId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

module queryManagedIdentityOperatorRole '../templates/role-definitions.bicep' = {
  name: 'query-${managedIdentityOperatorRoleObjectId}'
  params: {
    roleId: managedIdentityOperatorRoleObjectId
  }
}

module queryVmContributorRole '../templates/role-definitions.bicep' = {
  name: 'query-${virtualMachineContributorRoleObjectId}'
  params: {
    roleId: virtualMachineContributorRoleObjectId
  }
}

resource assignVmContributerRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(virtualMachineContributorRoleObjectId)
  scope: resourceGroup()
  properties:{
    principalId: principalId
    roleDefinitionId: queryVmContributorRole.outputs.id
    principalType: 'ServicePrincipal'
    description: 'for AAD Pod Identity'
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

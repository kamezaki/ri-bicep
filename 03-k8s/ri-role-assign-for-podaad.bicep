@description('Application name')
param appName string = 'fabrikam'
@description('location for this resource')
param location string = resourceGroup().location

@description('target ask cluster name')
param aksClusterName string = appName
@description('Optional: if you are planning to deploy your user-assigned identities in a separate resource group instead of your node resource group')
param identityResourceGroup string = ''

// Managed Identity Operator
var managedIdentityOperatorRoleObjectId = 'f1a07417-d97a-45cb-824c-7a7467783830'
// Virtual Machine Contributor
var virtualMachineContributorRoleObjectId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

// query aks resource
module cluster '../templates/query-aks.bicep' = {
  name: 'query-${aksClusterName}'
  params: {
    name: aksClusterName
  }
}

module podAAD '../templates/pod-aad.bicep' = {
  name: 'nested-pod-aad-${aksClusterName}'
  params: {
    nodeResourceGroupName: cluster.outputs.nodeResourceGroup
    principalId: cluster.outputs.principalId
  }
}

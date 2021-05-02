@description('cluster node resource group name')
param nodeResourceGroupName string
@description('principal id of cluster nodes')
param principalId string
@description('your resource group that is used to store your user-assigned identities assuming it is within the same subscription as your AKS node resource group')
param identityResourceGroupName string = ''

module assignNodePodAADRole 'assign-node-rg-pod-aad.bicep' = {
  name: 'assign-pod-aad-rg-${nodeResourceGroupName}'
  scope: resourceGroup(nodeResourceGroupName)
  params:{
    principalId: principalId
  }
}

module assignIdentityPodAADRole 'assign-identity-rg-pod-aad.bicep' = if (!empty(identityResourceGroupName)){
  name: 'assign-pod-aad-rg-${identityResourceGroupName}'
  scope: resourceGroup(identityResourceGroupName)
  params:{
    principalId: principalId
  }
} 

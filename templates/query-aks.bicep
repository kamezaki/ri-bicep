@description('query aks cluster name')
param name string

resource cluster 'Microsoft.ContainerService/managedClusters@2020-12-01' existing = {
  name: name
}

output id string = cluster.id
output principalId string = any(cluster.properties.identityProfile.kubeletidentity).objectId

@description('location for aks cluster')
param location string = resourceGroup().location
@description('execute cluster version')
param kubernetesVersion string
@description('AKS cluster name')
param clusterName string 
@description('The DNS prefix to use with hosted Kubernetes API server FQDN')
param dnsPrefix string = clusterName
@description('default agent pool name')
@minLength(1)
@maxLength(12)
param defaultAgentPoolName  string = 'defaultpool'
@description('availability zone array')
param availabilityZones array = []
@description('The mininum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
@minValue(1)
@maxValue(50)
param agentMinCount int = 1
@description('The maximum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
@minValue(1)
@maxValue(100)
param agentMaxCount int = agentMinCount
@description('VM size for agent node')
param agentVMSize string = 'Standard_D2_v3'
@description('Node disk size in GB')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0
@description('Node resource group name')
param nodeResourceGroup string = json('null')
@description('service princilal client id')
param servicePrincipalId string = 'msi'
@description('service principal secret')
param servicePrincipalSecret string = json('null')
@description('subnet refernce')
param subnetRef string = json('null')
@description('Log analytics workspace id')
param workspaceId string = json('null')
@description('tags for aks cluster')
param tags object = json('null')

// Azure kubernetes service
resource aks 'Microsoft.ContainerService/managedClusters@2020-12-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: defaultAgentPoolName
        count: agentMinCount
        minCount: agentMinCount
        maxCount: agentMaxCount
        osDiskSizeGB: osDiskSizeGB
        mode: 'System'
        vmSize: agentVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: true
        availabilityZones: length(availabilityZones) == 0 ? json('null') : availabilityZones
        vnetSubnetID: subnetRef
      }
    ]
    servicePrincipalProfile: {
      clientId: servicePrincipalId
      secret: servicePrincipalSecret
    }
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: 'azure'  // use Azure CNI
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      omsagent: empty(workspaceId) ? json('null') : {
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
        enabled: true
      }
    }
  }
}

output id string = aks.id
output name string = aks.name
output apiServerAddress string = aks.properties.fqdn
output principalId string = aks.identity.principalId

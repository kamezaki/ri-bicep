@description('Role id')
param roleId string

resource roleDef 'Microsoft.Authorization/roleDefinitions@2015-07-01' existing = {
  scope: subscription()
  name: roleId
}

output id string = roleDef.id

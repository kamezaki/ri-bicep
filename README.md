# Deploy reference implemantation using bicep

```
export APP_NAME="ri-app"
```

## Create app and resource group

1. az ad sp create-for-rbac --name ${APP_NAME}
1. create prerequisite resources see [01-prerequisite](01-prerequisite/README.md)

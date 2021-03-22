# Deploy reference implemantation using bicep

```
export APP_NAME="ri-app"
export RESOURCE_GROUP="ri-app-rg"
export LOCATION="japaneast"
```

## Create app and resource group

```
az ad sp create-for-rbac --name ${APP_NAME}

az group add --name ${RESOURCE_GROUP} --location ${LOCATION}
```

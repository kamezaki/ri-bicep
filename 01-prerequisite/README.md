# Deploy prerequiste resources

## create resources

- create resource group (default name `ri-app-rg`)
- make managed identities for delivery/droneScheduler/workflow

## How to deploy

You should put your location with --location option.

```
az deployment sub create -f ri-prereqs.bicep --location japaneast
```
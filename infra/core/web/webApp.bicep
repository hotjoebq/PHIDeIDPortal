@description('Name of the Web App')
param webAppName string = 'webname'
@description('Runtime for the Web App')
param runtime string = 'DOTNET|8.0'
@description('App Service plan name for the Web App')
param appServicePlanName string
@description('Location for the Web App')
param location string = resourceGroup().location
@description('Tags to apply to the Web App')
param tags object = {}
@description('Azure Cosmos DB endpoint')
param cosmosEndpoint string = ''
@description('Azure Search Service endpoint')
param searchServiceEndpoint string = ''
@description('Azure Search Service API key')
@secure()
param searchServiceApiKey string = ''
@description('Azure Storage Account endpoint')
param storageAccountEndpoint string = ''
@description('Azure Storage Account name')
param storageAccountName string = ''

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app'
  tags: tags
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      windowsFxVersion: runtime
      appSettings: [
        {
          name: 'AZURE_COSMOS_ENDPOINT'
          value: cosmosEndpoint
        }
        {
          name: 'CosmosDb__Endpoint'
          value: cosmosEndpoint
        }
        {
          name: 'CosmosDb__DatabaseId'
          value: 'deid'
        }
        {
          name: 'CosmosDb__ContainerId'
          value: 'metadata'
        }
        {
          name: 'CosmosDb__PartitionKey'
          value: '/Uri'
        }
        {
          name: 'CosmosDb__UseEntraAuth'
          value: 'true'
        }
        {
          name: 'AZURE_SEARCH_SERVICE_ENDPOINT'
          value: searchServiceEndpoint
        }
        {
          name: 'AZURE_SEARCH_SERVICE_API_KEY'
          value: searchServiceApiKey
        }
        {
          name: 'SearchService__Uri'
          value: searchServiceEndpoint
        }
        {
          name: 'SearchService__ApiKey'
          value: searchServiceApiKey
        }
        {
          name: 'SearchService__IndexName'
          value: 'piiredaction'
        }
        {
          name: 'SearchService__DefaultIndexerName'
          value: 'piiredaction-unstructured'
        }
        {
          name: 'SearchService__ReindexOnUpload'
          value: 'true'
        }
        {
          name: 'AZURE_STORAGE_ACCOUNT_ENDPOINT'
          value: storageAccountEndpoint
        }
        {
          name: 'AZURE_STORAGE_ACCOUNT_NAME'
          value: storageAccountName
        }
        {
          name: 'StorageAccount__Uri'
          value: storageAccountEndpoint
        }
        {
          name: 'StorageAccount__AccountName'
          value: storageAccountName
        }
        {
          name: 'StorageAccount__UseManagedIdentity'
          value: 'true'
        }
        {
          name: 'StorageAccount__Container'
          value: 'pii-sample-unstructured'
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource publishingPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  parent: webApp
  // scope: rg
  // location: location
  properties: {
    allow: true
  }
  // dependsOn: [
  //   webApp
  // ]
}

output webAppName string = webApp.name
output webAppId string = webApp.id
output webAppPrincipalId string = webApp.identity.principalId

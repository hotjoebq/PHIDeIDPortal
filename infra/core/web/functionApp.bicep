@description('Name of the Function App')
param functionAppName string = 'functionappname'
// @description('OS type for the Function App')
// param osType string = 'Windows'
@description('Runtime for the Function App')
param runtime string = 'dotnet-isolated'
// @description('Storage account resource for the Function App')
// param roleAssignmentScope resource 'Microsoft.Storage/storageAccounts@2023-01-01'
@description('Storage account name for the Function App')
param storageAccountName string
@description('App Service plan name for the Function App')
param appServicePlanName string
@description('Location for the Function App')
param location string = resourceGroup().location
@description('Tags to apply to the Function App')
param tags object = {}
@description('Azure OpenAI endpoint')
param openAiEndpoint string = ''
@description('Azure OpenAI deployment name')
param openAiDeploymentName string = ''
@description('Azure OpenAI API key')
@secure()
param openAiApiKey string = ''


// resource existingStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
// � name: 'storage'
// }


resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  tags: tags
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
        {
          name: 'OPENAI_ENDPOINT'
          value: openAiEndpoint
        }
        {
          name: 'OPENAI_DEPLOYMENT_NAME'
          value: openAiDeploymentName
        }
        {
          name: 'OPENAI_API_KEY'
          value: openAiApiKey
        }
        {
          name: 'PII_REDACTION_PROMPT'
          value: 'You are a PII detection system. Analyze the following text and identify all personally identifiable information (PII) including names, SSNs, phone numbers, addresses, email addresses, dates of birth, and medical record numbers. Return your response as JSON with PiiFound (boolean) and PiiDetails (array of objects with Text, Type, and Context fields).'
        }
      ]
      use32BitWorkerProcess: false
      linuxFxVersion: ''
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// resource storageBlobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(functionApp.id, 'Storage Blob Data Contributor')
//   scope: existingStorage // roleAssignmentScope // storageAccountResource // resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
//     principalId: functionApp.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output functionAppPrincipalId string = functionApp.identity.principalId

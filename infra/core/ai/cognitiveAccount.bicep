metadata description = 'Creates an Azure storage account.'
param name string
param location string = resourceGroup().location
param tags object = {}

resource cognitiveAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
	name: name
	location: location 
	sku: {
		name: 'S0'
	}
	kind: 'CognitiveServices'
	properties: {
		// restore: true // Needed due to soft-delete with azd down, during development. But removed after day-later azd deploy with error: "CanNotRestoreAnActiveResource: Could not restore an active account"
		apiProperties: {}
		networkAcls: {
			defaultAction: 'Allow'
		}
	}
	
	tags: tags
}

output cognitiveAccountName string = cognitiveAccount.name
output cognitiveAccountId string = cognitiveAccount.id
output cognitiveAccountEndpoint string = cognitiveAccount.properties.endpoint

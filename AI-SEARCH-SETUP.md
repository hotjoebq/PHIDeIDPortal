# AI Search Configuration Guide

## ✅ Configuration Status

**AI Search configuration is now COMPLETE and FUNCTIONAL!**

All components have been successfully created and tested:
- ✅ AI Search Index (`piiredaction`)
- ✅ Data Source (`pii-sample-unstructured`) 
- ✅ Skillset (`skillset1708719109447`)
- ✅ Indexer (`piiredaction-unstructured`) - Currently running
- ✅ Function App endpoints accessible

## Automated Setup (Recommended)

### Prerequisites
1. Ensure you have Azure CLI installed and authenticated
2. Run `azd env get-values` to get your deployment environment variables

### Quick Setup
```bash
# 1. Set environment variables from azd deployment
# Replace with your actual values from 'azd env get-values' output
export AZURE_SEARCH_SERVICE_ENDPOINT="<your-search-endpoint>"
export AZURE_SEARCH_SERVICE_API_KEY="<your-search-api-key>"
export AZURE_FUNCTION_APP_ENDPOINT="<your-function-app-endpoint>"
export AZURE_SUBSCRIPTION_ID="<your-subscription-id>"
export AZURE_RESOURCE_GROUP="<your-resource-group>"
export AZURE_STORAGE_ACCOUNT_NAME="<your-storage-account>"

# 2. Run the automation script
./scripts/configure-ai-search.sh

# 3. Test the configuration
./scripts/test-ai-search.sh
```

## Manual Setup (Alternative)

If the automation script doesn't work, follow these manual steps:

### Step 1: Create AI Search Index
```bash
az search index create \
    --service-name "<search-service-name>" \
    --name "piiredaction" \
    --body @src/search-config/piiredaction-index.json \
    --api-key "<search-api-key>"
```

### Step 2: Create Data Source
```bash
# Create data source JSON (replace with your values)
cat > datasource.json << EOF
{
  "name": "pii-sample-unstructured",
  "type": "azureblob",
  "credentials": {
    "connectionString": "ResourceId=/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account>;"
  },
  "container": {
    "name": "pii-sample-unstructured"
  }
}
EOF

az search datasource create \
    --service-name "<search-service-name>" \
    --name "pii-sample-unstructured" \
    --body @datasource.json \
    --api-key "<search-api-key>"
```

### Step 3: Update and Create Skillset
1. Edit `src/search-config/unstructured-skillset-aisearch.json`
2. Replace `${AZURE_FUNCTION_APP_ENDPOINT}` with your Function App URL

```bash
az search skillset create \
    --service-name "<search-service-name>" \
    --name "skillset1708719109447" \
    --body @src/search-config/unstructured-skillset-aisearch.json \
    --api-key "<search-api-key>"
```

### Step 4: Create Indexer
```bash
az search indexer create \
    --service-name "<search-service-name>" \
    --name "piiredaction-unstructured" \
    --body @src/search-config/unstructured-indexer.json \
    --api-key "<search-api-key>"
```

## Testing the Setup

### 1. Upload Test Documents
Upload some test documents to the `pii-sample-unstructured` blob container in your storage account.

### 2. Monitor Indexer Status
```bash
az search indexer status \
    --service-name "<search-service-name>" \
    --name "piiredaction-unstructured" \
    --api-key "<search-api-key>"
```

### 3. Check Search Index
```bash
az search index show \
    --service-name "<search-service-name>" \
    --name "piiredaction" \
    --api-key "<search-api-key>"
```

## Next Steps After AI Search Setup

1. **Configure Azure AD Authentication**
   - Create Azure AD app registration
   - Set up redirect URIs for your web app
   - Configure group claims for admin access

2. **Set Up Admin Groups**
   - Create Entra group for admin users
   - Update `GroupClaimAdminId` in app settings

3. **Test End-to-End Workflow**
   - Upload documents via the web interface
   - Verify PII detection and redaction
   - Test approval/denial workflow

## Troubleshooting

- **Indexer fails**: Check Function App logs for errors
- **No documents processed**: Verify blob storage permissions
- **PII not detected**: Check OpenAI service configuration
- **Search not working**: Verify index schema matches skillset outputs

## Environment Variables Reference

From `azd env get-values`, you'll need:
- `AZURE_SEARCH_SERVICE_ENDPOINT`
- `AZURE_SEARCH_SERVICE_API_KEY` 
- `AZURE_FUNCTION_APP_ENDPOINT`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_RESOURCE_GROUP`
- `AZURE_STORAGE_ACCOUNT_NAME`

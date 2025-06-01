# PHI De-identification Portal - Complete Deployment Guide

This guide provides step-by-step instructions for deploying the PHI De-identification Portal to Azure using Azure Developer CLI (azd) with all the latest fixes and improvements.

## 📋 Prerequisites

- Azure CLI installed and configured
- Azure Developer CLI (azd) installed
- Git configured with access to the repository
- VS Code or terminal access
- Azure subscription access with Contributor permissions

## 🎯 Target Environment

- **Subscription ID**: `e748553e-76b8-4431-af0b-4d479db02282`
- **Resource Group**: `rg-hj-dev7RG`
- **Repository**: `hotjoebq/PHIDeIDPortal`
- **Branch with Fixes**: `devin/1748729626-azure-deployment-fixes`

## 🚀 Complete Deployment Steps

### Step 1: Authentication and Setup

```bash
# Authenticate with Azure CLI
az login

# Set the target subscription
az account set --subscription e748553e-76b8-4431-af0b-4d479db02282

# Verify subscription is set correctly
az account show --query "{subscriptionId:id, name:name, user:user.name}"

# Authenticate with Azure Developer CLI
azd auth login
```

### Step 2: Clone Repository and Checkout Latest Changes

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/hotjoebq/PHIDeIDPortal.git
cd PHIDeIDPortal

# Or if already cloned, navigate to the directory
cd PHIDeIDPortal

# Fetch latest changes from remote
git fetch origin

# Checkout the branch with all the deployment fixes
git checkout devin/1748729626-azure-deployment-fixes

# Pull latest changes to ensure you have all updates
git pull origin devin/1748729626-azure-deployment-fixes

# Verify you're on the correct branch
git branch --show-current
git log --oneline -5
```

### Step 3: Initialize Azure Developer Environment

```bash
# Initialize azd environment (choose a unique environment name)
azd env new <your-environment-name>

# Set required environment variables
azd env set AZURE_SUBSCRIPTION_ID e748553e-76b8-4431-af0b-4d479db02282
azd env set AZURE_LOCATION eastus2
azd env set AZURE_RESOURCE_GROUP rg-hj-dev7RG

# Verify environment variables are set
azd env get-values
```

### Step 4: Deploy Infrastructure and Applications

```bash
# Deploy everything (infrastructure + applications)
azd up

# If you encounter any issues, you can run components separately:
# azd provision  # Deploy infrastructure only
# azd deploy     # Deploy applications only
```

### Step 5: Verify Deployment

```bash
# Check deployment status
azd show

# List all deployed resources
az resource list --resource-group rg-hj-dev7RG --output table

# Get the web application URL
az webapp show --name app-broqnvwzoti46 --resource-group rg-hj-dev7RG --query "defaultHostName" --output tsv
```

### Step 6: Configure AI Search Components (Post-Deployment)

```bash
# Navigate to search configuration directory
cd src/search-config

# Create the search index
curl -X POST "https://srch-broqnvwzoti46.search.windows.net/indexes?api-version=2023-11-01" \
  -H "Content-Type: application/json" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)" \
  -d @piiredaction-index.json

# Create the skillset
curl -X POST "https://srch-broqnvwzoti46.search.windows.net/skillsets?api-version=2023-11-01" \
  -H "Content-Type: application/json" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)" \
  -d @unstructured-skillset-aisearch.json

# Create the data source
curl -X POST "https://srch-broqnvwzoti46.search.windows.net/datasources?api-version=2023-11-01" \
  -H "Content-Type: application/json" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)" \
  -d @unstructured-datasource.json

# Create the indexer
curl -X POST "https://srch-broqnvwzoti46.search.windows.net/indexers?api-version=2023-11-01" \
  -H "Content-Type: application/json" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)" \
  -d @unstructured-indexer.json

# Return to root directory
cd ../..
```

### Step 7: Test the Application

```bash
# Get the web application URL
echo "Web Application URL: https://$(az webapp show --name app-broqnvwzoti46 --resource-group rg-hj-dev7RG --query "defaultHostName" --output tsv)"

# Get the Function App URL
echo "Function App URL: https://$(az functionapp show --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG --query "defaultHostName" --output tsv)"

# Test Function App health
curl "https://$(az functionapp show --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG --query "defaultHostName" --output tsv)/api/health"
```

## 🔧 Key Features Deployed

### ✅ Authentication Bypass
- Temporary authentication bypass implemented for testing
- Upload functionality accessible without Azure AD authentication
- TabbedNavigation component renders correctly with test user

### ✅ Azure Resources
- **Web App**: `app-broqnvwzoti46` - Main PHI De-identification Portal
- **Function App**: `func-broqnvwzoti46` - Custom skills for PII detection
- **AI Search**: `srch-broqnvwzoti46` - Document indexing and search
- **Storage Account**: `stbroqnvwzoti46` - Document storage
- **Cosmos DB**: `cosmos-broqnvwzoti46` - Metadata storage
- **OpenAI**: `aoai-broqnvwzoti46` - GPT-4o-mini for PII detection

### ✅ Document Processing Pipeline
1. **Upload**: Documents uploaded to `pii-sample-unstructured` container
2. **Indexing**: AI Search processes documents through skillset
3. **PII Detection**: OpenAI function identifies and redacts PII
4. **Metadata Sync**: Results stored in Cosmos DB
5. **Display**: Processed documents appear in web interface

## 🔍 Monitoring and Troubleshooting

### Check AI Search Indexer Status
```bash
# Get indexer status
curl -X GET "https://srch-broqnvwzoti46.search.windows.net/indexers/unstructured-indexer/status?api-version=2023-11-01" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)" | jq '.'

# Manually trigger indexer if needed
curl -X POST "https://srch-broqnvwzoti46.search.windows.net/indexers/unstructured-indexer/run?api-version=2023-11-01" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)"
```

### Check Function App Logs
```bash
# Stream Function App logs
az functionapp log tail --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG

# Check Function App status
az functionapp show --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG --query "{name:name, state:state, hostNames:hostNames}"
```

### Verify Storage Account Access
```bash
# List storage containers
az storage container list --account-name stbroqnvwzoti46 --auth-mode login --output table

# Check role assignments
az role assignment list --scope "/subscriptions/e748553e-76b8-4431-af0b-4d479db02282/resourceGroups/rg-hj-dev7RG/providers/Microsoft.Storage/storageAccounts/stbroqnvwzoti46" --output table
```

## 🔄 Updating the Deployment

### For Code Changes
```bash
# Pull latest changes
git pull origin devin/1748729626-azure-deployment-fixes

# Deploy only the applications (faster than full deployment)
azd deploy
```

### For Infrastructure Changes
```bash
# Pull latest changes
git pull origin devin/1748729626-azure-deployment-fixes

# Deploy everything
azd up
```

## 🚨 Common Issues and Solutions

### Issue: "Cannot connect to storage account"
**Solution**: Check managed identity role assignments
```bash
az role assignment create --assignee $(az webapp identity show --name app-broqnvwzoti46 --resource-group rg-hj-dev7RG --query principalId -o tsv) --role "Storage Blob Data Contributor" --scope "/subscriptions/e748553e-76b8-4431-af0b-4d479db02282/resourceGroups/rg-hj-dev7RG/providers/Microsoft.Storage/storageAccounts/stbroqnvwzoti46"
```

### Issue: Upload button not visible
**Solution**: Authentication bypass is already implemented in the deployed code

### Issue: Documents stuck in "Uploaded" status
**Solution**: Manually trigger the AI Search indexer
```bash
curl -X POST "https://srch-broqnvwzoti46.search.windows.net/indexers/unstructured-indexer/run?api-version=2023-11-01" \
  -H "api-key: $(az search admin-key show --resource-group rg-hj-dev7RG --service-name srch-broqnvwzoti46 --query primaryKey -o tsv)"
```

### Issue: Function App not responding
**Solution**: Restart the Function App
```bash
az functionapp restart --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG
```

## 📊 Expected Results

After successful deployment:
- ✅ Web application accessible at: `https://app-broqnvwzoti46.azurewebsites.net/`
- ✅ Upload button visible and functional
- ✅ Document upload workflow operational
- ✅ PII detection pipeline configured (may need manual indexer trigger)
- ✅ All Azure resources provisioned and configured

## 🔐 Security Notes

- Authentication is temporarily bypassed for testing purposes
- In production, implement proper Azure AD authentication
- Storage account access is restricted to managed identities
- Function App uses managed identity for secure resource access

## 📞 Support

If you encounter issues:
1. Check the Azure Portal for resource status
2. Review Function App logs for errors
3. Verify AI Search indexer execution history
4. Ensure all role assignments are properly configured

---

**Deployment completed successfully!** 🎉

The PHI De-identification Portal is now ready for testing with full upload functionality and PII detection capabilities.

#!/bin/bash


set -e

if [ -z "$AZURE_SEARCH_SERVICE_ENDPOINT" ] || [ -z "$AZURE_SEARCH_SERVICE_API_KEY" ] || [ -z "$AZURE_FUNCTION_APP_ENDPOINT" ]; then
    echo "Error: Required environment variables not set. Please run 'azd env get-values' to see available variables."
    echo "Required: AZURE_SEARCH_SERVICE_ENDPOINT, AZURE_SEARCH_SERVICE_API_KEY, AZURE_FUNCTION_APP_ENDPOINT"
    exit 1
fi

SEARCH_SERVICE_NAME=$(echo $AZURE_SEARCH_SERVICE_ENDPOINT | sed 's|https://||' | sed 's|\.search\.windows\.net||')

echo "Configuring AI Search components for service: $SEARCH_SERVICE_NAME"
echo "Function App endpoint: $AZURE_FUNCTION_APP_ENDPOINT"

TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TEMP_DIR"

substitute_vars() {
    local input_file=$1
    local output_file=$2
    
    sed "s|\${AZURE_FUNCTION_APP_ENDPOINT}|$AZURE_FUNCTION_APP_ENDPOINT|g" "$input_file" > "$output_file"
}

echo "Step 1: Creating AI Search Index..."
cp "src/search-config/piiredaction-index.json" "$TEMP_DIR/index.json"

az search index create \
    --service-name "$SEARCH_SERVICE_NAME" \
    --name "piiredaction" \
    --body @"$TEMP_DIR/index.json" \
    --api-key "$AZURE_SEARCH_SERVICE_API_KEY"

echo "✅ AI Search Index created successfully"

echo "Step 2: Creating Data Source..."
cat > "$TEMP_DIR/datasource.json" << EOF
{
  "name": "pii-sample-unstructured",
  "type": "azureblob",
  "credentials": {
    "connectionString": "ResourceId=/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$AZURE_STORAGE_ACCOUNT_NAME;"
  },
  "container": {
    "name": "pii-sample-unstructured"
  }
}
EOF

az search datasource create \
    --service-name "$SEARCH_SERVICE_NAME" \
    --name "pii-sample-unstructured" \
    --body @"$TEMP_DIR/datasource.json" \
    --api-key "$AZURE_SEARCH_SERVICE_API_KEY"

echo "✅ Data Source created successfully"

echo "Step 3: Creating Skillset with Function App endpoints..."
substitute_vars "src/search-config/unstructured-skillset-aisearch.json" "$TEMP_DIR/skillset.json"

az search skillset create \
    --service-name "$SEARCH_SERVICE_NAME" \
    --name "skillset1708719109447" \
    --body @"$TEMP_DIR/skillset.json" \
    --api-key "$AZURE_SEARCH_SERVICE_API_KEY"

echo "✅ Skillset created successfully"

echo "Step 4: Creating Indexer..."
cp "src/search-config/unstructured-indexer.json" "$TEMP_DIR/indexer.json"

az search indexer create \
    --service-name "$SEARCH_SERVICE_NAME" \
    --name "piiredaction-unstructured" \
    --body @"$TEMP_DIR/indexer.json" \
    --api-key "$AZURE_SEARCH_SERVICE_API_KEY"

echo "✅ Indexer created successfully"

rm -rf "$TEMP_DIR"

echo ""
echo "🎉 AI Search configuration completed successfully!"
echo ""
echo "Next steps:"
echo "1. Upload test documents to the 'pii-sample-unstructured' blob container"
echo "2. Monitor indexer status: az search indexer status --service-name $SEARCH_SERVICE_NAME --name piiredaction-unstructured --api-key \$AZURE_SEARCH_SERVICE_API_KEY"
echo "3. Configure Azure AD authentication for the web application"
echo ""
echo "Your PHI De-identification Portal is now ready for document processing!"

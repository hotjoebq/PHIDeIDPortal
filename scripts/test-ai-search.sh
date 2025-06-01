#!/bin/bash

set -e


if [ -z "$AZURE_SEARCH_SERVICE_ENDPOINT" ] || [ -z "$AZURE_SEARCH_SERVICE_API_KEY" ] || [ -z "$AZURE_FUNCTION_APP_ENDPOINT" ]; then
    echo "Error: Required environment variables not set. Please run 'azd env get-values' to see available variables."
    echo "Required: AZURE_SEARCH_SERVICE_ENDPOINT, AZURE_SEARCH_SERVICE_API_KEY, AZURE_FUNCTION_APP_ENDPOINT"
    exit 1
fi

echo "Testing AI Search configuration..."

echo "Test 1: Checking if index 'piiredaction' exists..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "$AZURE_SEARCH_SERVICE_ENDPOINT/indexes/piiredaction?api-version=2023-11-01" \
    -H "api-key: $AZURE_SEARCH_SERVICE_API_KEY")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Index 'piiredaction' exists"
else
    echo "❌ Index 'piiredaction' not found (HTTP $HTTP_STATUS)"
    exit 1
fi

echo "Test 2: Checking if data source 'pii-sample-unstructured' exists..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "$AZURE_SEARCH_SERVICE_ENDPOINT/datasources/pii-sample-unstructured?api-version=2023-11-01" \
    -H "api-key: $AZURE_SEARCH_SERVICE_API_KEY")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Data source 'pii-sample-unstructured' exists"
else
    echo "❌ Data source 'pii-sample-unstructured' not found (HTTP $HTTP_STATUS)"
    exit 1
fi

echo "Test 3: Checking if skillset 'skillset1708719109447' exists..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "$AZURE_SEARCH_SERVICE_ENDPOINT/skillsets/skillset1708719109447?api-version=2023-11-01" \
    -H "api-key: $AZURE_SEARCH_SERVICE_API_KEY")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Skillset 'skillset1708719109447' exists"
else
    echo "❌ Skillset 'skillset1708719109447' not found (HTTP $HTTP_STATUS)"
    exit 1
fi

echo "Test 4: Checking if indexer 'piiredaction-unstructured' exists..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "$AZURE_SEARCH_SERVICE_ENDPOINT/indexers/piiredaction-unstructured?api-version=2023-11-01" \
    -H "api-key: $AZURE_SEARCH_SERVICE_API_KEY")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Indexer 'piiredaction-unstructured' exists"
else
    echo "❌ Indexer 'piiredaction-unstructured' not found (HTTP $HTTP_STATUS)"
    exit 1
fi

echo "Test 5: Checking indexer status..."
INDEXER_RESPONSE=$(curl -s \
    "$AZURE_SEARCH_SERVICE_ENDPOINT/indexers/piiredaction-unstructured/status?api-version=2023-11-01" \
    -H "api-key: $AZURE_SEARCH_SERVICE_API_KEY")

if echo "$INDEXER_RESPONSE" | grep -q '"status":"success"'; then
    echo "✅ Indexer last run was successful"
elif echo "$INDEXER_RESPONSE" | grep -q '"status":"inProgress"'; then
    echo "⏳ Indexer is currently running"
elif echo "$INDEXER_RESPONSE" | grep -q '"lastResult":null'; then
    echo "ℹ️ Indexer has not run yet"
else
    echo "⚠️ Indexer status: $(echo "$INDEXER_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)"
fi

echo "Test 6: Testing Function App endpoint..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$AZURE_FUNCTION_APP_ENDPOINT")

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "404" ]; then
    echo "✅ Function App endpoint is accessible (HTTP $HTTP_STATUS)"
else
    echo "⚠️ Function App endpoint returned HTTP $HTTP_STATUS"
fi

echo ""
echo "🎉 AI Search configuration test completed!"
echo ""
echo "Next steps:"
echo "1. Upload test documents to the 'pii-sample-unstructured' blob container"
echo "2. Run the indexer using REST API or Azure portal"
echo "3. Monitor indexer progress and check for processed documents"

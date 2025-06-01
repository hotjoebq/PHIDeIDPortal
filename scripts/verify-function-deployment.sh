#!/bin/bash


echo "🔍 Verifying Azure Functions deployment..."
echo "Function App: func-broqnvwzoti46"
echo "Resource Group: rg-hj-dev7RG"
echo ""

echo "1. Listing deployed functions..."
az functionapp function list --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG --output table

echo ""
echo "2. Testing function endpoints..."

FUNCTION_APP_URL="https://func-broqnvwzoti46.azurewebsites.net"

FUNCTIONS=("OpenAiRedactionFunction" "MetadataSyncFunction" "RegexRedactionFunction" "WordRedactionFunction")

for func in "${FUNCTIONS[@]}"; do
    echo "Testing $func..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "$FUNCTION_APP_URL/api/$func")
    if [ "$response" = "404" ]; then
        echo "❌ $func: 404 Not Found (function not deployed)"
    elif [ "$response" = "401" ]; then
        echo "✅ $func: 401 Unauthorized (function deployed, needs auth)"
    elif [ "$response" = "200" ]; then
        echo "✅ $func: 200 OK (function deployed and accessible)"
    else
        echo "⚠️  $func: HTTP $response (unexpected response)"
    fi
done

echo ""
echo "3. Checking Function App runtime status..."
az functionapp show --name func-broqnvwzoti46 --resource-group rg-hj-dev7RG --query "state" --output tsv

echo ""
echo "✅ Verification complete!"
echo "Expected results after fixing FUNCTIONS_WORKER_RUNTIME:"
echo "- 5 functions should be listed"
echo "- HTTP endpoints should return 401/200 (not 404)"

# Project

PHI Deidentification Portal

## Deployment Instructions using Azure Developer CLI (azd)

![318910463-a3d9905d-6df7-4e2d-b0eb-d0c4e7e2ecb5](https://github.com/microsoft/PHIDeIDPortal/assets/112185610/1f74e6b9-0f94-40db-9fa8-aadd04433d24)

### Prerequisites
1. Install [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
2. Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Login to Azure: `az login`

### Deployment Steps
1. Clone or Fork this repository
2. Navigate to the project directory: `cd PHIDeIDPortal`
3. Initialize azd environment: `azd env new <environment-name>`
4. Set target subscription: `azd env set AZURE_SUBSCRIPTION_ID e748553e-76b8-4431-af0b-4d479db02282`
5. Set target location: `azd env set AZURE_LOCATION <your-preferred-region>`
6. Deploy infrastructure and applications: `azd up`
7. Configure AI Search components:
   - Create the AI Search Index using `src/search-config/piiredaction-index.json`
   - Create the Skillset using `src/search-config/unstructured-skillset-aisearch.json`
   - Create the Indexer using `src/search-config/unstructured-indexer.json`
8. Upload test documents to the storage container and verify the indexer processes them

### Post-Deployment Configuration
- Configure Azure AD app registration for authentication
- Set up Entra group for admin access
- Update GroupClaimAdminId in app settings

### Development Setup
For local development, copy `src/custom-skills/local.settings.json.template` to `src/custom-skills/local.settings.json` and fill in the appropriate values from your Azure deployment.

### Hybrid Approach Recommendations
Pure azd is recommended for this deployment as it handles:
- Infrastructure provisioning
- Application deployment
- Environment variable configuration
- Role assignments

Consider hybrid approaches (azd + custom scripts) when you need:
- Complex post-deployment configuration (AI Search setup)
- Custom data seeding or migration scripts
- Integration with external systems
- Advanced monitoring and alerting setup

This project conforms to the MIT licensing terms. Code is not indended as a complete production-ready solution and no warranty is implied.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

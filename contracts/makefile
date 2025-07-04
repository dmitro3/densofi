-include .env

.PHONY: help deploy-sepolia deploy-flow verify-sepolia verify-flow test test-launchpad-fork test-launchpad-flow-fork clean get-address show-config-sepolia show-config-flow generate-abis sync-contracts build-and-sync

help:
	@echo "Available commands:"
	@echo "  make deploy-sepolia   - Deploy contracts to Sepolia testnet"
	@echo "  make deploy-flow      - Deploy contracts to Flow mainnet"
	@echo "  make deploy-flow-simple - Deploy to Flow using simplified script (recommended)"
	@echo "  make verify-sepolia   - Verify contracts on Sepolia after deployment"
	@echo "  make verify-flow      - Verify contracts on Flow after deployment"
	@echo "  make show-config-sepolia - Show Sepolia configuration before deployment"
	@echo "  make show-config-flow    - Show Flow configuration before deployment"
	@echo "  make test            - Run forge tests"
	@echo "  make test-launchpad-fork - Run DensoFi Launchpad tests with mainnet fork"
	@echo "  make test-launchpad-flow-fork - Run DensoFi Launchpad tests with Flow fork"
	@echo "  make get-address     - Get your wallet address from private key"
	@echo "  make generate-abis   - Generate ABI files for all contracts"
	@echo "  make sync-contracts  - Sync contract ABIs and addresses to frontend and backend"
	@echo "  make build-and-sync  - Generate ABIs and sync to frontend and backend"
	@echo "  make clean           - Clean build artifacts"

# Check if required environment variables are set
check-env:
	@if [ -z "$(PRIVATE_KEY)" ]; then \
		echo "Error: PRIVATE_KEY is not set. Add it to .env file or export it."; \
		exit 1; \
	fi

check-env-sepolia: check-env
	@if [ -z "$(SEPOLIA_RPC_URL)" ]; then \
		echo "Error: SEPOLIA_RPC_URL is not set. Add it to .env file or export it."; \
		echo "Example: SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your-api-key"; \
		exit 1; \
	fi

check-env-flow: check-env
	@if [ -z "$(FLOW_RPC_URL)" ]; then \
		echo "Error: FLOW_RPC_URL is not set. Add it to .env file or export it."; \
		echo "Example: FLOW_RPC_URL=https://mainnet.evm.nodes.onflow.org"; \
		exit 1; \
	fi

# Show configuration before deployment
show-config-sepolia: check-env-sepolia
	@echo "Showing Sepolia configuration..."
	@forge script script/ShowChainConfig.s.sol --rpc-url $(SEPOLIA_RPC_URL)

show-config-flow: check-env-flow
	@echo "Showing Flow configuration..."
	@forge script script/ShowChainConfig.s.sol --rpc-url $(FLOW_RPC_URL)

# Deploy to Sepolia
deploy-sepolia: check-env-sepolia
	@echo "Deploying to Sepolia..."
	@mkdir -p deployment-addresses
	@forge script script/DeployContracts.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast -vvv
	@echo "Deployment complete. Addresses saved to deployment-addresses/11155111-addresses.json"

# Deploy to Flow
deploy-flow: check-env-flow
	@echo "Deploying to Flow..."
	@mkdir -p deployment-addresses
	@forge script script/SimpleDeployContracts.s.sol --rpc-url $(FLOW_RPC_URL) --broadcast --legacy -vvv
	@echo "Deployment complete. Addresses saved to deployment-addresses/747-addresses.json"

# Verify contracts on Sepolia
verify-sepolia: check-env-sepolia
	@if [ -z "$(ETHERSCAN_API_KEY)" ]; then \
		echo "Error: ETHERSCAN_API_KEY is not set for verification"; \
		exit 1; \
	fi
	@if [ ! -f "deployment-addresses/11155111-addresses.json" ]; then \
		echo "Error: Deployment addresses file not found. Deploy first with 'make deploy-sepolia'"; \
		exit 1; \
	fi
	@echo "Verifying contracts on Sepolia..."
	@echo "Reading deployment addresses from deployment-addresses/11155111-addresses.json"
	@echo ""
	@echo "Verifying DomainRegistration contract..."
	@forge verify-contract \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--constructor-args $$(cast abi-encode "constructor(uint256,address)" \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.domainRegistrationFee') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.deployer')) \
		$$(cat deployment-addresses/11155111-addresses.json | jq -r '.addresses.domainRegistration') \
		src/DomainRegistration.sol:DomainRegistration
	@echo ""
	@echo "Verifying NFTMinter contract..."
	@forge verify-contract \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--constructor-args $$(cast abi-encode "constructor(address)" \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.deployer')) \
		$$(cat deployment-addresses/11155111-addresses.json | jq -r '.addresses.nftMinter') \
		src/NFTMinter.sol:NFTMinter
	@echo ""
	@echo "Verifying TokenMinter contract..."
	@forge verify-contract \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--constructor-args $$(cast abi-encode "constructor(address,address,address)" \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.deployer') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.addresses.nftMinter') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.addresses.launchpad')) \
		$$(cat deployment-addresses/11155111-addresses.json | jq -r '.addresses.tokenMinter') \
		src/TokenMinter.sol:TokenMinter
	@echo ""
	@echo "Verifying DensoFiLaunchpad contract..."
	@forge verify-contract \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--constructor-args $$(cast abi-encode "constructor(address,address,address,address,address,address,bytes32)" \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.deployer') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.uniV3Router') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.uniV3Factory') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.nonfungiblePositionManager') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.weth') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.pythOracle') \
			$$(cat deployment-addresses/11155111-addresses.json | jq -r '.parameters.ethUsdPriceId')) \
		$$(cat deployment-addresses/11155111-addresses.json | jq -r '.addresses.launchpad') \
		src/DensofiLaunchpad.sol:DensoFiLaunchpad
	@echo ""
	@echo "All contracts verified on Sepolia!"

# Verify contracts on Flow
verify-flow: check-env-flow
	@if [ ! -f "deployment-addresses/747-addresses.json" ]; then \
		echo "Error: Deployment addresses file not found. Deploy first with 'make deploy-flow'"; \
		exit 1; \
	fi
	@echo "Verifying contracts on Flow using Blockscout..."
	@echo "Reading deployment addresses from deployment-addresses/747-addresses.json"
	@echo ""
	@echo "Verifying DomainRegistration contract..."
	@forge verify-contract \
		--rpc-url https://mainnet.evm.nodes.onflow.org/ \
		--verifier blockscout \
		--verifier-url 'https://evm.flowscan.io/api/' \
		$$(cat deployment-addresses/747-addresses.json | jq -r '.addresses.domainRegistration') \
		src/DomainRegistration.sol:DomainRegistration
	@echo ""
	@echo "Verifying NFTMinter contract..."
	@forge verify-contract \
		--rpc-url https://mainnet.evm.nodes.onflow.org/ \
		--verifier blockscout \
		--verifier-url 'https://evm.flowscan.io/api/' \
		$$(cat deployment-addresses/747-addresses.json | jq -r '.addresses.nftMinter') \
		src/NFTMinter.sol:NFTMinter
	@echo ""
	@echo "Verifying TokenMinter contract..."
	@forge verify-contract \
		--rpc-url https://mainnet.evm.nodes.onflow.org/ \
		--verifier blockscout \
		--verifier-url 'https://evm.flowscan.io/api/' \
		$$(cat deployment-addresses/747-addresses.json | jq -r '.addresses.tokenMinter') \
		src/TokenMinter.sol:TokenMinter
	@echo ""
	@echo "Verifying DensoFiLaunchpad contract..."
	@forge verify-contract \
		--rpc-url https://mainnet.evm.nodes.onflow.org/ \
		--verifier blockscout \
		--verifier-url 'https://evm.flowscan.io/api/' \
		$$(cat deployment-addresses/747-addresses.json | jq -r '.addresses.launchpad') \
		src/DensofiLaunchpad.sol:DensoFiLaunchpad
	@echo ""
	@echo "All contracts verified on Flow!"

# Run tests
test:
	@echo "Running tests..."
	@$(MAKE) test-no-fork
	@$(MAKE) test-launchpad-fork
	@$(MAKE) test-launchpad-flow-fork

test-no-fork:
	@echo "Running tests..."
	@forge test -vv

# Run DensoFi Launchpad tests with mainnet fork
test-launchpad-fork:
	@echo "Running DensoFi Launchpad tests with mainnet fork..."
	@forge test --match-contract DensoFiLaunchpadTest --fork-url https://eth-mainnet.public.blastapi.io -vv

# Run DensoFi Launchpad tests with Flow fork
test-launchpad-flow-fork: check-env-flow
	@echo "Running DensoFi Launchpad tests with Flow fork..."
	@forge test --match-contract DensoFiLaunchpadTest --fork-url $(FLOW_RPC_URL) -vv

get-address: check-env
	@echo "Your public address is:"
	@cast wallet address --private-key $(PRIVATE_KEY)

# Generate ABI files for all contracts
generate-abis:
	@echo "Generating ABI files for all contracts..."
	@mkdir -p abis
	@forge build
	@echo "Extracting ABIs from compiled contracts..."
	@if [ -f "out/DomainRegistration.sol/DomainRegistration.json" ]; then \
		jq '.abi' out/DomainRegistration.sol/DomainRegistration.json > abis/DomainRegistration.json; \
		echo "Generated abis/DomainRegistration.json"; \
	fi
	@if [ -f "out/NFTMinter.sol/NFTMinter.json" ]; then \
		jq '.abi' out/NFTMinter.sol/NFTMinter.json > abis/NFTMinter.json; \
		echo "Generated abis/NFTMinter.json"; \
	fi
	@if [ -f "out/TokenMinter.sol/TokenMinter.json" ]; then \
		jq '.abi' out/TokenMinter.sol/TokenMinter.json > abis/TokenMinter.json; \
		echo "Generated abis/TokenMinter.json"; \
	fi
	@if [ -f "out/DensofiLaunchpad.sol/DensoFiLaunchpad.json" ]; then \
		jq '.abi' out/DensofiLaunchpad.sol/DensoFiLaunchpad.json > abis/DensoFiLaunchpad.json; \
		echo "Generated abis/DensoFiLaunchpad.json"; \
	fi
	@if [ -f "out/DensofiUniV3Vault.sol/DensofiUniV3Vault.json" ]; then \
		jq '.abi' out/DensofiUniV3Vault.sol/DensofiUniV3Vault.json > abis/DensofiUniV3Vault.json; \
		echo "Generated abis/DensofiUniV3Vault.json"; \
	fi
	@if [ -f "out/InitialSupplySuperchainERC20.sol/InitialSupplySuperchainERC20.json" ]; then \
		jq '.abi' out/InitialSupplySuperchainERC20.sol/InitialSupplySuperchainERC20.json > abis/InitialSupplySuperchainERC20.json; \
		echo "Generated abis/InitialSupplySuperchainERC20.json"; \
	fi
	@echo "ABI generation complete. Files saved to abis/ directory"

# Sync contract ABIs and addresses to frontend and backend
sync-contracts:
	@echo "Syncing contract ABIs and addresses to frontend and backend..."
	@echo ""
	
	# Create target directories if they don't exist
	@mkdir -p ../frontend/constants/abis
	@mkdir -p ../frontend/constants/deployment-addresses
	@mkdir -p ../backend/src/constants/abis
	@mkdir -p ../backend/src/constants/deployment-addresses
	
	@echo "📋 Syncing ABIs..."
	# Copy ABIs to frontend
	@if [ -d "abis" ]; then \
		cp -r abis/* ../frontend/constants/abis/ 2>/dev/null || true; \
		echo "✅ Frontend ABIs synced"; \
	else \
		echo "⚠️  ABIs directory not found. Run 'make generate-abis' first"; \
	fi
	
	# Copy ABIs to backend
	@if [ -d "abis" ]; then \
		cp -r abis/* ../backend/src/constants/abis/ 2>/dev/null || true; \
		echo "✅ Backend ABIs synced"; \
	else \
		echo "⚠️  ABIs directory not found. Run 'make generate-abis' first"; \
	fi
	
	@echo "📍 Syncing deployment addresses..."
	# Copy deployment addresses to frontend
	@if [ -d "deployment-addresses" ]; then \
		cp -r deployment-addresses/* ../frontend/constants/deployment-addresses/ 2>/dev/null || true; \
		echo "✅ Frontend deployment addresses synced"; \
	else \
		echo "⚠️  No deployment addresses found"; \
	fi
	
	# Copy deployment addresses to backend
	@if [ -d "deployment-addresses" ]; then \
		cp -r deployment-addresses/* ../backend/src/constants/deployment-addresses/ 2>/dev/null || true; \
		echo "✅ Backend deployment addresses synced"; \
	else \
		echo "⚠️  No deployment addresses found"; \
	fi
	
	@echo ""
	@echo "🎉 Contract sync complete!"
	@echo ""
	@echo "Synced files:"
	@echo "  ABIs: contracts/abis/* → {frontend/constants/abis/, backend/src/constants/abis/}"
	@echo "  Addresses: contracts/deployment-addresses/* → {frontend/constants/deployment-addresses/, backend/src/constants/deployment-addresses/}"

# Generate ABIs and sync to frontend and backend in one command
build-and-sync: generate-abis sync-contracts
	@echo "✅ Build and sync complete!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@forge clean
	@rm -rf abis
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ICreateX} from "@createx/ICreateX.sol";

import {DomainRegistration} from "../src/DomainRegistration.sol";
import {NFTMinter} from "../src/NFTMinter.sol";
import {TokenMinter} from "../src/TokenMinter.sol";
import {DensoFiLaunchpad} from "../src/DensofiLaunchpad.sol";
import {ChainConfig} from "./ChainConfig.sol";

/**
 * @title DeployContracts
 * @notice This script deploys all contracts across multiple chains using deterministic addresses
 * @dev Uses the CreateX contract for deterministic cross-chain deployment
 */
contract DeployContracts is Script {
    // Deployment addresses
    address public domainRegistrationAddress;
    address public nftMinterAddress;
    address public tokenMinterAddress;
    address public launchpadAddress;

    // Salt for deterministic deployments
    bytes32 private salt;

    // Chain configuration
    ChainConfig.ChainParameters private chainParams;

    // CreateX instance
    ICreateX private createX;

    // Deployer address (will be set as owner)
    address private deployer;

    function setUp() public {
        salt = bytes32(uint256(0x696942069420694206969));
    }

    function run() public {
        uint256 privateKeyInt = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKeyInt);

        // Set deployer address
        deployer = vm.addr(privateKeyInt);
        console2.log("Deploying with address:", deployer);

        // Get chain-specific parameters
        chainParams = ChainConfig.getChainParameters(block.chainid);
        console2.log("Using chain ID:", block.chainid);
        console2.log(
            "Domain registration fee:",
            chainParams.domainRegistrationFee
        );

        // Check if CreateX is already deployed
        address createXAddress = 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed;
        bool useCreateX = _isContract(createXAddress);

        if (useCreateX) {
            createX = ICreateX(createXAddress);
            console2.log("Using CreateX at:", createXAddress);
        } else {
            console2.log("CreateX not available, using regular deployment");
            console2.log(
                "Note: Addresses will not be deterministic across chains"
            );
        }

        // Deploy contracts
        deployContracts(useCreateX);

        console2.log("\nDeployments complete!");
        console2.log(
            "DomainRegistration deployed at:",
            domainRegistrationAddress
        );
        console2.log("NFTMinter deployed at:", nftMinterAddress);
        console2.log("TokenMinter deployed at:", tokenMinterAddress);
        console2.log("Launchpad deployed at:", launchpadAddress);

        // Save deployment addresses to JSON file
        saveDeploymentAddresses();

        vm.stopBroadcast();
    }

    function deployContracts(bool useCreateX) internal {
        if (useCreateX) {
            _deployWithCreateX();
        } else {
            _deployRegular();
        }
    }

    function _deployWithCreateX() internal {
        // 1. Deploy DomainRegistration with deployer as owner
        bytes memory domainRegistrationInitCode = abi.encodePacked(
            type(DomainRegistration).creationCode,
            abi.encode(chainParams.domainRegistrationFee, deployer)
        );

        domainRegistrationAddress = createX.deployCreate2(
            salt,
            domainRegistrationInitCode
        );
        console2.log("\nDeploying DomainRegistration...");
        console2.log(
            "DomainRegistration deployed at:",
            domainRegistrationAddress
        );

        // 2. Deploy NFTMinter with deployer as owner
        bytes memory nftMinterInitCode = abi.encodePacked(
            type(NFTMinter).creationCode,
            abi.encode(deployer)
        );

        bytes32 nftMinterSalt = bytes32(uint256(salt) + 1);
        nftMinterAddress = createX.deployCreate2(
            nftMinterSalt,
            nftMinterInitCode
        );
        console2.log("\nDeploying NFTMinter...");
        console2.log("NFTMinter deployed at:", nftMinterAddress);

        // 3. Deploy Launchpad with chain-specific parameters
        bytes memory launchpadInitCode = abi.encodePacked(
            type(DensoFiLaunchpad).creationCode,
            abi.encode(
                deployer, // _owner
                chainParams.uniV3Router, // _uniV3Router
                chainParams.uniV3Factory, // _uniV3Factory
                chainParams.nonfungiblePositionManager, // _nonfungiblePositionManager
                chainParams.weth, // _weth
                chainParams.pythOracle, // _pythOracle
                chainParams.ethUsdPriceId // _ethUsdPriceId
            )
        );

        bytes32 launchpadSalt = bytes32(uint256(salt) + 2);
        launchpadAddress = createX.deployCreate2(
            launchpadSalt,
            launchpadInitCode
        );
        console2.log("\nDeploying Launchpad...");
        console2.log("Launchpad deployed at:", launchpadAddress);

        // 4. Deploy TokenMinter with deployer as owner, NFTMinter address, and Launchpad address
        bytes memory tokenMinterInitCode = abi.encodePacked(
            type(TokenMinter).creationCode,
            abi.encode(deployer, nftMinterAddress, launchpadAddress)
        );

        bytes32 tokenMinterSalt = bytes32(uint256(salt) + 3);
        tokenMinterAddress = createX.deployCreate2(
            tokenMinterSalt,
            tokenMinterInitCode
        );
        console2.log("\nDeploying TokenMinter...");
        console2.log("TokenMinter deployed at:", tokenMinterAddress);
    }

    function _deployRegular() internal {
        console2.log("\nDeploying DomainRegistration...");
        DomainRegistration domainRegistration = new DomainRegistration(
            chainParams.domainRegistrationFee,
            deployer
        );
        domainRegistrationAddress = address(domainRegistration);
        console2.log(
            "DomainRegistration deployed at:",
            domainRegistrationAddress
        );

        console2.log("\nDeploying NFTMinter...");
        NFTMinter nftMinter = new NFTMinter(deployer);
        nftMinterAddress = address(nftMinter);
        console2.log("NFTMinter deployed at:", nftMinterAddress);

        console2.log("\nDeploying Launchpad...");
        DensoFiLaunchpad launchpad = new DensoFiLaunchpad(
            deployer,
            chainParams.uniV3Router,
            chainParams.uniV3Factory,
            chainParams.nonfungiblePositionManager,
            chainParams.weth,
            chainParams.pythOracle,
            chainParams.ethUsdPriceId
        );
        launchpadAddress = address(launchpad);
        console2.log("Launchpad deployed at:", launchpadAddress);

        console2.log("\nDeploying TokenMinter...");
        TokenMinter tokenMinter = new TokenMinter(
            deployer,
            nftMinterAddress,
            launchpadAddress
        );
        tokenMinterAddress = address(tokenMinter);
        console2.log("TokenMinter deployed at:", tokenMinterAddress);
    }

    function saveDeploymentAddresses() internal {
        string memory json = string(
            abi.encodePacked(
                "{\n",
                '  "chainId": ',
                vm.toString(block.chainid),
                ",\n",
                '  "deployer": "',
                vm.toString(deployer),
                '",\n',
                '  "addresses": {\n',
                '    "domainRegistration": "',
                vm.toString(domainRegistrationAddress),
                '",\n',
                '    "nftMinter": "',
                vm.toString(nftMinterAddress),
                '",\n',
                '    "tokenMinter": "',
                vm.toString(tokenMinterAddress),
                '",\n',
                '    "launchpad": "',
                vm.toString(launchpadAddress),
                '"\n',
                "  },\n",
                '  "parameters": {\n',
                '    "domainRegistrationFee": "',
                vm.toString(chainParams.domainRegistrationFee),
                '",\n',
                '    "uniV3Router": "',
                vm.toString(chainParams.uniV3Router),
                '",\n',
                '    "uniV3Factory": "',
                vm.toString(chainParams.uniV3Factory),
                '",\n',
                '    "nonfungiblePositionManager": "',
                vm.toString(chainParams.nonfungiblePositionManager),
                '",\n',
                '    "weth": "',
                vm.toString(chainParams.weth),
                '",\n',
                '    "pythOracle": "',
                vm.toString(chainParams.pythOracle),
                '",\n',
                '    "ethUsdPriceId": "',
                vm.toString(chainParams.ethUsdPriceId),
                '",\n',
                '    "tokenMinterFixedFee": "',
                vm.toString(chainParams.tokenMinterFixedFee),
                '"\n',
                "  }\n",
                "}"
            )
        );

        string memory filename = string(
            abi.encodePacked(
                "deployment-addresses/",
                vm.toString(block.chainid),
                "-addresses.json"
            )
        );

        vm.writeFile(filename, json);
        console2.log("Deployment addresses saved to:", filename);
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

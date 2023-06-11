require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("solidity-coverage");
require("hardhat-gas-reporter");
require("dotenv").config();
require("hardhat-deploy");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [{ version: "0.6.7" }, { version: "0.8.18" }],
  },
  paths: {
    artifacts: '../client/src/artifacts',
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },

  networks: {
    hardhat: {
      chainId: 31337,
    },
    mumbai: {
      url: process.env.MUMBAI_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    goerli: {
      url: process.env.GOERLI_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    binance: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      url: process.env.MAINNET_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    token: "ETH",
    gasPriceApi: "api.etherscan.io/api?module=proxy&action=eth_gasPrice",
    outputFile: "gas-report.txt",
    coinmarketcap: process.env.COINMARKETCAP,
    noColors: true,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
  },
  mocha: {
    timeout: 500000,
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.MAINNET_API_KEY,
      polygonMumbai: process.env.POLYGON_API_KEY,
      binance: process.env.BINANCE_API_KEY,
      goerli: process.env.ETHSCAN_API_KEY,
    },
  },
};
require("babel-register");
require("babel-polyfill");

const Ganache = require("ganache-core");

const HDWalletProvider = require("truffle-hdwallet-provider");
require("dotenv").config();

const mnemonic = process.env.MNEMONIC;
const mnemonicTest = process.env.MNEMONIC_TEST;

const providerUrl = "https://ropsten.infura.io";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 4700000,
      gasPrice: 20e9,
    },
    test: {
      network_id: "*",
      provider() {
        return Ganache.provider({
          network_id: "7",
          seed: mnemonicTest,
          default_balance_ether: 1e30,
          total_accounts: 50,
          debug: true,
          logger: null,
          port: 7544,
          locked: false,
        });
      },
      gas: 4700000,
      gasPrice: 20e9,
    },
    ropsten: {
      network_id: 3,
      provider() {
        return new HDWalletProvider(mnemonic, providerUrl, 0, 50);
      },
      gas: 4700000,
      gasPrice: 100e9,
    },
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};

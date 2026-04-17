require("@nomiclabs/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    chainA: {
      url: "http://127.0.0.1:8545",
    },
    chainB: {
      url: "http://127.0.0.1:8546",
    },
  },
};
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    besu: {
      url: "http://localhost:8546",
      gasPrice: 0,
      accounts: ["c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3"]
    }
  },
  solidity: "0.8.24",
};

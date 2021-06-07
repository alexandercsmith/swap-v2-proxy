require('dotenv').config();

/**
 * @package
 */
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-waffle');

/**
 * @module tasks 
 */
require('./tasks');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.3",
  networks: {
    mainnet: {
      url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`]
    },
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`]
    }
  }
};
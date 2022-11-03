require('@nomiclabs/hardhat-waffle');
require("@nomiclabs/hardhat-ethers");
require('dotenv').config();

const {PRIVATE_KEY, MUMBAI_ALCHEMY_API_URL} = process.env;

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.10',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
     }
   },
    networks: {
    hardhat: {},
      polygon_mumbai: {
        url: MUMBAI_ALCHEMY_API_URL, // YOUR_ALCHEMY_MUMBAI_URL
        accounts: [`0x${PRIVATE_KEY}`], // YOUR_TEST_WALLET_PRIVATE_KEY,
      },
    },
  }
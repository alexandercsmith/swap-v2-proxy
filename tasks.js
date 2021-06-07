/**
 * @module tasks 
 * @desc   smart contract automation tasks
 */

const { task } = require('hardhat/config');

task('utils', 'Automation Utility Task')
  .addPositionalParam('command', 'Utility Command Action')
  .addOptionalPositionalParam('address', 'Account or Smart Contract Address', process.env.WALLET_ADDRESS)
  .setAction(async (args, { ethers }) => {
    /* address */
    const address = ethers.utils.getAddress(args.address);

    /* method */
    let result;
    switch (args.command) {

      /* $ hh utils balance <address> */
      case 'balance': 
        const balance = await ethers.provider.getBalance(address);
        result = ethers.constants.EtherSymbol + ' ' + ethers.utils.formatEther(balance.toString());
        break;

      /* $ hh utils checksum <address> */
      case 'checksum':
        result = address;
        break;

      /* $ hh utils txns <address> */
      case 'txns':
        result = await ethers.provider.getTransactionCount(address);
        break;

      default:
        result = address;
    }

    /* output */
    console.log('\n=>', result, '\n');
  });
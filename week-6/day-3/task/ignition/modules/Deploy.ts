import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MultiSigWalletModule = buildModule("MultiSigWalletModule", (m) => {

  const admins = ['0x583031D1113aD414F02576BD6afaBfb302140225', '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4', '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2']

  const multiSigWallet = m.contract("MultiSigWallet", [admins]);

  return { multiSigWallet };
});

export default MultiSigWalletModule;
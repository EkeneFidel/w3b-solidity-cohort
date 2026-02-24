import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SaveAssetModule = buildModule("SaveAssetModule", (m) => {
  const erc20 = m.contract("ERC20");

  const saveAsset = m.contract("SaveAsset", [erc20]);

  return { erc20, saveAsset };
});

export default SaveAssetModule;
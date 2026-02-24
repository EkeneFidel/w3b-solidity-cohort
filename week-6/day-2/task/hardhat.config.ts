import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv';

dotenv.config();

const {
  PRIVATE_KEY,
  CELO_URL,
  ETHERSCAN_API_KEY
} = process.env as { [key: string]: string };

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    celoSepolia: {
      url: CELO_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
    customChains: [
      {
        network: "celoSepolia",
        chainId: 11142220,
        urls: {
          apiURL: "https://api.etherscan.io/v2/api",
          browserURL: "https://sepolia.celoscan.io",
        },
      }
    ],
  },
};

export default config;
const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const tokenAddress = process.env.TOKEN_ADDRESS;
  const merkleRoot = process.env.MERKLE_ROOT;
  const treasury = process.env.TREASURY;

  if (!tokenAddress || !merkleRoot || !treasury) {
    throw new Error("Missing TOKEN_ADDRESS, MERKLE_ROOT or TREASURY in .env");
  }

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const Airdrop = await hre.ethers.getContractFactory("CTXAirdrop");
  const airdrop = await Airdrop.deploy(
    deployer.address,
    tokenAddress,
    merkleRoot,
    treasury
  );

  await airdrop.waitForDeployment();

  console.log("CTXAirdrop deployed to:", await airdrop.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

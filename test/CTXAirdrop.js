const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CTXAirdrop", function () {
  let owner, user, treasury;
  let token, airdrop;

  beforeEach(async function () {
    [owner, user, treasury] = await ethers.getSigners();

    const MockToken = await ethers.getContractFactory("MockToken");
    token = await MockToken.deploy();
    await token.waitForDeployment();

    const leaf = ethers.keccak256(
      ethers.solidityPacked(["address", "uint256"], [user.address, 1000])
    );

    const Airdrop = await ethers.getContractFactory("CTXAirdrop");
    airdrop = await Airdrop.deploy(
      owner.address,
      await token.getAddress(),
      leaf,
      treasury.address
    );
    await airdrop.waitForDeployment();

    await token.transfer(await airdrop.getAddress(), 1000);
  });

  it("should allow a valid claim", async function () {
    await airdrop.connect(user).claim(1000, []);
    expect(await token.balanceOf(user.address)).to.equal(1000);
  });

  it("should prevent double claim", async function () {
    await airdrop.connect(user).claim(1000, []);
    await expect(
      airdrop.connect(user).claim(1000, [])
    ).to.be.revertedWith("Already claimed");
  });
});

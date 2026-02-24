import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("SaveAsset", function () {
    const ONE_ETH = ethers.parseEther("1");
    const TOKEN_AMOUNT = ethers.parseUnits("500", 18);

    async function deploySaveAssetFixture() {
        const [owner, ekene] = await ethers.getSigners();

        const ERC20 = await ethers.getContractFactory("ERC20");
        const token = await ERC20.deploy();

        const SaveAsset = await ethers.getContractFactory("SaveAsset");
        const saveAsset = await SaveAsset.deploy(await token.getAddress());

        await token.mint(ekene.address, TOKEN_AMOUNT);

        return { saveAsset, token, owner, ekene };
    }

    it("should deposit ETH and update balance", async function () {
        const { saveAsset, ekene } = await loadFixture(deploySaveAssetFixture);

        await saveAsset.connect(ekene).deposit({ value: ONE_ETH });
        expect(await saveAsset.balances(ekene.address)).to.equal(ONE_ETH);
    });

    it("should return error on deposit when value is zero", async function () {
        const { saveAsset, ekene } = await loadFixture(deploySaveAssetFixture);

        await expect(
            saveAsset.connect(ekene).deposit({ value: 0 })
        ).to.be.revertedWith("Can't deposit zero value");
    });

    it("should withdraw ETH and update balance", async function () {
        const { saveAsset, ekene } = await loadFixture(deploySaveAssetFixture);

        await saveAsset.connect(ekene).deposit({ value: ONE_ETH });
        await saveAsset.connect(ekene).withdraw(ONE_ETH);
        expect(await saveAsset.balances(ekene.address)).to.equal(0);
    });

    it("should deposit ERC20 and record savings", async function () {
        const { saveAsset, token, ekene } = await loadFixture(deploySaveAssetFixture);

        await token.connect(ekene).approve(await saveAsset.getAddress(), TOKEN_AMOUNT);
        await saveAsset.connect(ekene).depositERC20(TOKEN_AMOUNT);
        expect(await saveAsset.connect(ekene).getErc20SavingsBalance()).to.equal(TOKEN_AMOUNT);
    });

    it("should withdraw ERC20 and return tokens to user", async function () {
        const { saveAsset, token, ekene } = await loadFixture(deploySaveAssetFixture);

        await token.connect(ekene).approve(await saveAsset.getAddress(), TOKEN_AMOUNT);
        await saveAsset.connect(ekene).depositERC20(TOKEN_AMOUNT);
        await saveAsset.connect(ekene).withdrawERC20(TOKEN_AMOUNT);
        expect(await token.balanceOf(ekene.address)).to.equal(TOKEN_AMOUNT);
    });

    it("should return error on ERC20 withdraw when savings are insufficient", async function () {
        const { saveAsset, ekene } = await loadFixture(deploySaveAssetFixture);

        await expect(
            saveAsset.connect(ekene).withdrawERC20(TOKEN_AMOUNT)
        ).to.be.revertedWith("Not enough savings");
    });
});
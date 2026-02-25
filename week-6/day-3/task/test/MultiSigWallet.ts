import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("MultiSigWallet", function () {
    const ONE_ETH = ethers.parseEther("1");
    const HALF_ETH = ethers.parseEther("0.5");

    async function deployMultiSigFixture() {
        const [admin1, admin2, admin3, admin4, requester, recipient, other] =
            await ethers.getSigners();

        const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
        const wallet = await MultiSigWallet.deploy([
            admin1.address,
            admin2.address,
            admin3.address,
            admin4.address,
        ]);

        await requester.sendTransaction({
            to: await wallet.getAddress(),
            value: ONE_ETH,
        });

        return {
            wallet,
            admin1,
            admin2,
            admin3,
            admin4,
            requester,
            recipient,
            other,
        };
    }

    it("should accept ETH deposits from anyone", async function () {
        const { wallet, requester } = await loadFixture(deployMultiSigFixture);

        expect(await ethers.provider.getBalance(await wallet.getAddress())).to.equal(
            ONE_ETH
        );

        await requester.sendTransaction({
            to: await wallet.getAddress(),
            value: HALF_ETH,
        });

        expect(await ethers.provider.getBalance(await wallet.getAddress())).to.equal(
            ONE_ETH + HALF_ETH
        );
    });

    it("should allow anyone to request a withdrawal", async function () {
        const { wallet, requester, recipient } = await loadFixture(
            deployMultiSigFixture
        );

        const tx = await wallet
            .connect(requester)
            .requestWithdrawal(recipient.address, HALF_ETH);

        await expect(tx)
            .to.emit(wallet, "WithdrawalRequested")
            .withArgs(0, requester.address, recipient.address, HALF_ETH);

        const req = await wallet.requests(0);
        expect(req.requester).to.equal(requester.address);
        expect(req.to).to.equal(recipient.address);
        expect(req.amount).to.equal(HALF_ETH);
        expect(req.approvals).to.equal(0);
        expect(req.executed).to.equal(false);
    });

    it("should reject approvals from non-admin", async function () {
        const { wallet, requester, recipient, other } = await loadFixture(
            deployMultiSigFixture
        );

        await wallet
            .connect(requester)
            .requestWithdrawal(recipient.address, HALF_ETH);

        await expect(wallet.connect(other).approve(0)).to.be.revertedWith(
            "Not admin"
        );
    });

    it("should let admins approve, but not approve twice", async function () {
        const { wallet, requester, recipient, admin1 } = await loadFixture(
            deployMultiSigFixture
        );

        await wallet
            .connect(requester)
            .requestWithdrawal(recipient.address, HALF_ETH);

        await expect(wallet.connect(admin1).approve(0))
            .to.emit(wallet, "Approved")
            .withArgs(0, admin1.address);

        await expect(wallet.connect(admin1).approve(0)).to.be.revertedWith(
            "Already approved"
        );

        const req = await wallet.requests(0);
        expect(req.approvals).to.equal(1);
    });

    it("should not execute before 3 approvals", async function () {
        const { wallet, requester, recipient, admin1, admin2 } = await loadFixture(
            deployMultiSigFixture
        );

        await wallet
            .connect(requester)
            .requestWithdrawal(recipient.address, HALF_ETH);

        await wallet.connect(admin1).approve(0);
        await wallet.connect(admin2).approve(0);

        await expect(wallet.execute(0)).to.be.revertedWith("Not enough approvals");
    });

    it("should execute after 3 approvals and transfer ETH", async function () {
        const { wallet, requester, recipient, admin1, admin2, admin3 } =
            await loadFixture(deployMultiSigFixture);

        await wallet
            .connect(requester)
            .requestWithdrawal(recipient.address, HALF_ETH);

        await wallet.connect(admin1).approve(0);
        await wallet.connect(admin2).approve(0);
        await wallet.connect(admin3).approve(0);

        const recipientBefore = await ethers.provider.getBalance(recipient.address);
        const walletBefore = await ethers.provider.getBalance(await wallet.getAddress());

        const execTx = await wallet.execute(0);

        await expect(execTx).to.emit(wallet, "Executed").withArgs(0);

        const recipientAfter = await ethers.provider.getBalance(recipient.address);
        const walletAfter = await ethers.provider.getBalance(await wallet.getAddress());

        expect(walletAfter).to.equal(walletBefore - HALF_ETH);
        expect(recipientAfter).to.equal(recipientBefore + HALF_ETH);

        const req = await wallet.requests(0);
        expect(req.executed).to.equal(true);
    });

    it("should prevent executing the same request twice", async function () {
        const { wallet, requester, recipient, admin1, admin2, admin3 } =
            await loadFixture(deployMultiSigFixture);

        await wallet
            .connect(requester)
            .requestWithdrawal(recipient.address, HALF_ETH);

        await wallet.connect(admin1).approve(0);
        await wallet.connect(admin2).approve(0);
        await wallet.connect(admin3).approve(0);

        await wallet.execute(0);

        await expect(wallet.execute(0)).to.be.revertedWith("Already executed");
    });

    it("should revert if wallet balance is insufficient at execution time", async function () {
        const { wallet, requester, recipient, admin1, admin2, admin3 } =
            await loadFixture(deployMultiSigFixture);

        const twoEth = ethers.parseEther("2");
        await wallet.connect(requester).requestWithdrawal(recipient.address, twoEth);

        await wallet.connect(admin1).approve(0);
        await wallet.connect(admin2).approve(0);
        await wallet.connect(admin3).approve(0);

        await expect(wallet.execute(0)).to.be.revertedWith("Insufficient balance");
    });

    it("should revert when requesting withdrawal with amount 0", async function () {
        const { wallet, requester, recipient } = await loadFixture(
            deployMultiSigFixture
        );

        await expect(
            wallet.connect(requester).requestWithdrawal(recipient.address, 0)
        ).to.be.revertedWith("Amount must be > 0");
    });
});
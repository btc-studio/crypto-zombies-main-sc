/* eslint-disable jest/valid-expect */
const { expect } = require("chai");
const { ethers } = require("hardhat");

const toWei = (num) => ethers.utils.parseEther(num.toString()); // 1 ether = 10**18 wei (wei is the smallest unit of ether)
const fromWei = (num) => ethers.utils.formatEther(num);

describe("NFTMarketplace", function () {
  let deployer, addr1, addr2, nft, ft, marketplace;
  let feePercent = 1;
  let zombieName = "Zng";
  beforeEach(async function () {
    // Get contract factories
    const BTCS = await ethers.getContractFactory("BTCSToken");
    const ZombieNFT = await ethers.getContractFactory("GiftPack");
    const Marketplace = await ethers.getContractFactory("Marketplace");
    // Get signers
    [deployer, addr1, addr2] = await ethers.getSigners();

    ft = await BTCS.deploy();
    nft = await ZombieNFT.deploy(ft.address);
    marketplace = await Marketplace.deploy(feePercent);

    // Send BTCS to addr1 and addr2
    ft.transfer(addr1.address, toWei(10));
    ft.transfer(addr2.address, toWei(10));
  });

  describe("Deployment", function () {
    it("Should track name and symbol of the nft collection", async function () {
      expect(await nft.name()).to.equal("BTCZombieNFT");
      expect(await nft.symbol()).to.equal("CZB");
    });
    it("Should track feeAccount and feePercent of the nft collection", async function () {
      expect(await marketplace.receivedFeeAccount()).to.equal(deployer.address);
      expect(await marketplace.feePercentOnSales()).to.equal(feePercent);
    });
  });

  describe("Minting NFTs", function () {
    beforeEach(async function () {
      // addr1 creates 3 random DNAs
      await nft.connect(addr1).openStarterPack();
      // addr2 creates 3 random DNAs
      await nft.connect(addr2).openStarterPack();
    });

    it("Should track each minted NFT", async function () {
      expect(await nft.tokenCount()).to.equal(12);

      expect(await nft.balanceOf(addr1.address)).to.equal(6);
      //   expect(await nft.tokenURI(1)).to.equal(URI);
      expect(await nft.balanceOf(addr2.address)).to.equal(6);
      //   expect(await nft.tokenURI(2)).to.equal(URI);
    });
  });

  describe("Making marketplace item", function () {
    beforeEach(async function () {
      // addr1 creates 3 random DNAs
      await nft.connect(addr1).openStarterPack();
      // addr1 approve marketplace to spend nft
      await nft.connect(addr1).setApprovalForAll(marketplace.address, true);
    });

    it("Should track newly created item, transfer NFT from seller to marketplace and emit Offered event", async function () {
      // addr1 offers their nft at a price of 1 BTCS
      await expect(
        marketplace
          .connect(addr1)
          .makeItem(nft.address, ft.address, 1, toWei(1))
      )
        .to.emit(marketplace, "Offered")
        .withArgs(1, nft.address, ft.address, 1, toWei(1), addr1.address);

      // Owner of the NFT should now be the marketplace
      expect(await nft.ownerOf(1)).to.equal(marketplace.address);

      // Get item from items mapping then check fields to ensure they are correct
      const item = await marketplace.items(1);
      expect(item.itemId).to.equal(1);
      expect(item.nft).to.equal(nft.address);
      expect(item.ft).to.equal(ft.address);
      expect(item.tokenId).to.equal(1);
      expect(item.price).to.equal(toWei(1));
      expect(item.sold).to.equal(false);
    });

    it("Should fail if price is set to zero", async function () {
      await expect(
        marketplace.connect(addr1).makeItem(nft.address, ft.address, 1, 0)
      ).to.be.revertedWith("Price must be greater than zero");
    });
  });

  describe("Remove items from marketplace", function () {
    beforeEach(async function () {
      // addr1 creates 3 random DNAs
      await nft.connect(addr1).openStarterPack();
      // addr1 approve marketplace to spend nft
      await nft.connect(addr1).setApprovalForAll(marketplace.address, true);
      // addr1 makes their nft a marketplace item
      await marketplace
        .connect(addr1)
        .makeItem(nft.address, ft.address, 1, toWei(2));
    });

    it("Should remove item from Marketplace, transfer ownership back to seller", async function () {
      // NFT with tokenId = 1 is currently listed on Marketplace -> Owner should be the Marketplace
      expect(await nft.ownerOf(1)).to.equal(marketplace.address);

      // Remove tokenId = 1 (ứng với itemId = 1) from Marketplace on behalf of addr2 (not the former owner)
      // Should revert
      await expect(
        marketplace.connect(addr2).unmakeItem(nft.address, 1)
      ).to.be.revertedWith(
        "Only owner of the NFT can remove item from Marketplace"
      );

      // Remove tokenId = 1 (ứng với itemId = 1) from Marketplace on behalf of addr1 (the former owner)
      await marketplace.connect(addr1).unmakeItem(nft.address, 1);
      // Now the owner of the NFT with tokenId = 1 should be addr1
      expect(await nft.ownerOf(1)).to.equal(addr1.address);
    });
  });

  describe("Purchasing marketplace items", function () {
    let price = 2;
    let totalPriceInWei;
    beforeEach(async function () {
      // addr1 mints an nft
      await nft.connect(addr1).openStarterPack();
      // addr1 approve marketplace to spend nft
      await nft.connect(addr1).setApprovalForAll(marketplace.address, true);
      // addr1 makes their nft a marketplace item
      await marketplace
        .connect(addr1)
        .makeItem(nft.address, ft.address, 1, toWei(2));
    });

    it("Should update item as sold, pay seller, transfer NFT to buyer, charge fees and emit a Bought event", async function () {
      const sellerInitialBTCSBal = await ft.balanceOf(addr1.address);
      const feeAccountInitialBTCSBal = await ft.balanceOf(deployer.address);
      const buyerInitialBTCSBal = await ft.balanceOf(addr2.address);

      // Fetch items total price (market fee + item price)
      totalPriceInWei = await marketplace.getTotalPrice(1);

      // ft contract approve marketplace to spend ft
      await ft.connect(addr2).approve(marketplace.address, totalPriceInWei);

      // addr2 purchases item
      await expect(marketplace.connect(addr2).purchaseItem(totalPriceInWei, 1))
        .to.emit(marketplace, "Bought")
        .withArgs(
          1,
          nft.address,
          ft.address,
          1,
          toWei(price),
          addr1.address,
          addr2.address
        );

      const sellerFinalBTCSBal = await ft.balanceOf(addr1.address);
      const feeAccountFinalBTCSBal = await ft.balanceOf(deployer.address);
      const buyerFinalBTCSBal = await ft.balanceOf(addr2.address);

      // Seller should receive payment for the price of the NFT sold
      expect(+fromWei(sellerFinalBTCSBal)).to.equal(
        +price + +fromWei(sellerInitialBTCSBal)
      );

      // Calculate fee
      const fee = (feePercent / 100) * price;
      // feeAccount should receive fee
      expect(+fromWei(feeAccountFinalBTCSBal)).to.equal(
        +fee + +fromWei(feeAccountInitialBTCSBal)
      );

      // Buyer should loss payment for the price of the NFT sold
      expect(+fromWei(buyerFinalBTCSBal)).to.equal(
        +fromWei(buyerInitialBTCSBal) - +price - +fee
      );

      // The buyer should now own the nft
      expect(await nft.ownerOf(1)).to.equal(addr2.address);

      // Item should be deleted from the array
      expect((await marketplace.items(1)).itemId).to.equal(0);
    });

    it("Should fail for invalid item ids, sold items and when not enough BTCS is paid", async function () {
      await ft.connect(addr2).approve(marketplace.address, totalPriceInWei);

      // Fails for invalid item ids
      await expect(
        marketplace.connect(addr2).purchaseItem(totalPriceInWei, 2)
      ).to.be.revertedWith("Item doesn't exist");
      await expect(
        marketplace.connect(addr2).purchaseItem(totalPriceInWei, 0)
      ).to.be.revertedWith("Item doesn't exist");

      // Fais when not enough BTCS is paid with the transaction.
      await expect(
        marketplace.connect(addr2).purchaseItem(price, 1)
      ).to.be.revertedWith(
        "Not enough BTCS to cover item price and market fee"
      );

      // addr2 purchases item 1
      await marketplace.connect(addr2).purchaseItem(totalPriceInWei, 1);
      // After purchasing -> Delete item from mapping (Data all zero)
      const item = await marketplace.items(1);
      expect(item.itemId).to.equal(0);
    });
  });
});

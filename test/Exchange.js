const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Exchange", () => {
  let ownerOfCardano,
    ownerOfTether,
    ownerOfZilliqa,
    ownerOfExchange,
    addr1,
    addr2,
    addr3,
    Exchange,
    exchange,
    Cardano,
    cardano,
    Tether,
    tether,
    Zilliqa,
    zilliqa;

  beforeEach("Exchange", async () => {
    [ownerOfCardano, ownerOfExchange, addr1, addr2, addr3] =
      await ethers.getSigners();
    Cardano = await ethers.getContractFactory("Cardano", ownerOfCardano);
    cardano = await Cardano.deploy();
    await cardano.deployed();
    Tether = await ethers.getContractFactory("Tether", ownerOfTether);
    tether = await Tether.deploy();
    await tether.deployed();
    Zilliqa = await ethers.getContractFactory("Zilliqa", ownerOfZilliqa);
    zilliqa = await Zilliqa.deploy();
    await zilliqa.deployed();
    Exchange = await ethers.getContractFactory("Exchange", ownerOfExchange);
    exchange = await Exchange.deploy(
      cardano.address,
      tether.address,
      zilliqa.address
    );
    await exchange.deployed();
  });

  describe("Deployment", async () => {
    it("cardanoOwner must has 100000000000000000 tokens on the balance", async () => {
      expect(await cardano.balanceOf(ownerOfCardano.address)).to.eq(
        "100000000000000000"
      );
    });
    it("should return right owner of Cardano token", async () => {
      expect(await cardano.cardanoOwner()).to.eq(ownerOfCardano.address);
    });
    it("should return Cardano token name", async () => {
      expect(await exchange.getTokenName(cardano.address)).to.eq("Cardano");
    });
    it("should return cardano address", async () => {
      expect(await exchange.getTokenById(0)).to.eq(cardano.address);
    });
    it("should return 0 index using cardano address", async () => {
      expect(await exchange.getTokenIdByToken(cardano.address)).to.eq(0);
    });
  });
});

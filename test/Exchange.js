const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Exchange", () => {
  let ownerOfCardano,
    ownerOfExchange,
    addr1,
    addr2,
    addr3,
    Exchange,
    exchange,
    Cardano,
    cardano;
  beforeEach("Exchange", async () => {
    [ownerOfCardano, ownerOfExchange, addr1, addr2, addr3] =
      await ethers.getSigners();
    Cardano = await ethers.getContractFactory("Cardano", ownerOfCardano);
    cardano = await Cardano.deploy();
    await cardano.deployed();
    Exchange = await ethers.getContractFactory("Exchange", ownerOfExchange);
    exchange = await Exchange.deploy(cardano);
    await exchange.deployed();
  });

  describe("Deployment", async () => {
    it("should return cardano address", async () => {
      const addr = await exchange.getC();
    });
  });
});

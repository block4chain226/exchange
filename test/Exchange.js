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
    [ownerOfCardano, ownerOfExchange, ownerOfZilliqa, addr1, addr2, addr3] =
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
  describe("buyTokens", async () => {
    it("should return 17 tokens of cardano using tokenIndex=0 and 32 tokens of zilliqa using tokenIndex=2 after buy tokens", async () => {
      //registration
      await exchange.connect(addr1).newUser();
      expect(await exchange._userExists(addr1.address)).to.eq(true);
      // approve
      await cardano.approve(exchange.address, 1000000);
      await zilliqa.approve(exchange.address, 1000000);
      expect(
        await cardano.allowance(ownerOfCardano.address, exchange.address)
      ).to.eq(1000000);
      expect(
        await zilliqa.allowance(ownerOfZilliqa.address, exchange.address)
      ).to.eq(1000000);
      //buy tokens
      await exchange
        .connect(addr1)
        .buyTokens(cardano.address, addr1.address, ownerOfCardano.address, {
          value: ethers.utils.parseEther("0.00000000000000045", "ether"),
        });
      await exchange
        .connect(addr1)
        .buyTokens(zilliqa.address, addr1.address, ownerOfZilliqa.address, {
          value: ethers.utils.parseEther("0.00000000000000138", "ether"),
        });
      const cardanoIndex = await exchange.getTokenIdByToken(cardano.address);
      console.log(
        "🚀 ~ file: Exchange.js ~ line 88 ~ it ~ cardanoIndex",
        cardanoIndex
      );
      const zilIndex = await exchange.getTokenIdByToken(zilliqa.address);
      console.log("🚀 ~ file: Exchange.js ~ line 89 ~ it ~ zilIndex", zilIndex);
      expect(
        await exchange.getUserTokenAmount(addr1.address, cardanoIndex)
      ).to.eq(17);
      expect(await exchange.getUserTokenAmount(addr1.address, zilIndex)).to.eq(
        32
      );
    });

    it("should return currenciesCount=2 of addr1 after buy tokens cardano and zil", async () => {
      //registration
      await exchange.connect(addr1).newUser();
      expect(await exchange._userExists(addr1.address)).to.eq(true);
      // approve
      await cardano.approve(exchange.address, 1000000);
      await zilliqa.approve(exchange.address, 1000000);
      expect(
        await cardano.allowance(ownerOfCardano.address, exchange.address)
      ).to.eq(1000000);
      expect(
        await zilliqa.allowance(ownerOfZilliqa.address, exchange.address)
      ).to.eq(1000000);
      //buy tokens
      await exchange
        .connect(addr1)
        .buyTokens(cardano.address, addr1.address, ownerOfCardano.address, {
          value: ethers.utils.parseEther("0.00000000000000045", "ether"),
        });
      await exchange
        .connect(addr1)
        .buyTokens(zilliqa.address, addr1.address, ownerOfZilliqa.address, {
          value: ethers.utils.parseEther("0.00000000000000138", "ether"),
        });
      expect(await exchange.getUserCurrenciesCount(addr1.address)).to.eq(2);
    });

    it("should return currenciesCount=1 of addr1 after buy tokens cardano and sell all cardano tokens", async () => {
      //registration
      await exchange.connect(addr1).newUser();
      const tx = {
        value: ethers.utils.parseEther("1", "ether"),
        to: exchange.address,
      };
      await addr1.sendTransaction(tx);
      expect(await exchange._userExists(addr1.address)).to.eq(true);
      // approve
      await cardano.approve(exchange.address, 1000000);
      await zilliqa.approve(exchange.address, 1000000);
      expect(
        await cardano.allowance(ownerOfCardano.address, exchange.address)
      ).to.eq(1000000);
      expect(
        await zilliqa.allowance(ownerOfZilliqa.address, exchange.address)
      ).to.eq(1000000);
      //buy tokens
      await exchange
        .connect(addr1)
        .buyTokens(cardano.address, addr1.address, ownerOfCardano.address, {
          value: ethers.utils.parseEther("0.0000000000001", "ether"),
        });
      await exchange
        .connect(addr1)
        .buyTokens(zilliqa.address, addr1.address, ownerOfZilliqa.address, {
          value: ethers.utils.parseEther("0.00000000000000138", "ether"),
        });
      await cardano.connect(addr1).approve(exchange.address, 4995);
      expect(await cardano.allowance(addr1.address, exchange.address)).to.eq(
        4995
      );
      ////sell
      console.log(await cardano.balanceOf(addr1.address));
      await exchange.connect(addr1).sellTokens(cardano.address, 4995);
      expect(await exchange.getUserCurrenciesCount(addr1.address)).to.eq(1);
    });

    it("after addr1 will buy tokens owner of exchange contract must get 200 wei of fee", async () => {});
  });

  describe.only("Swap", async () => {
    it("should return created swapOrder and User.swapOrderCount must equl 1", async () => {
      await exchange.connect(addr1).newUser();
      const tx = {
        value: ethers.utils.parseEther("1", "ether"),
        to: exchange.address,
      };
      await addr1.sendTransaction(tx);
      // approve
      await cardano.approve(exchange.address, 1000000);
      await zilliqa.approve(exchange.address, 1000000);
      expect(
        await cardano.allowance(ownerOfCardano.address, exchange.address)
      ).to.eq(1000000);
      expect(
        await zilliqa.allowance(ownerOfZilliqa.address, exchange.address)
      ).to.eq(1000000);
      //buy tokens
      await exchange
        .connect(addr1)
        .buyTokens(cardano.address, addr1.address, ownerOfCardano.address, {
          value: ethers.utils.parseEther("0.0000000000001", "ether"),
        });
      await exchange.connect(addr1).createSwapOrder(0, 1, 100, 22);
      expect(await exchange.getUserSwapOrdersCount(addr1.address)).to.eq(1);
    });

    it("after swap addr1 should have 61 zil on his balance and addr2 should have 98 ada on his balance", async () => {
      await exchange.connect(addr1).newUser();
      expect(await exchange._userExists(addr1.address)).to.eq(true);
      await exchange.connect(addr2).newUser();
      expect(await exchange._userExists(addr2.address)).to.eq(true);
      const tx = {
        value: ethers.utils.parseEther("1", "ether"),
        to: exchange.address,
      };
      await addr1.sendTransaction(tx);
      // approve
      await cardano.approve(exchange.address, 1000000);
      await zilliqa.approve(exchange.address, 1000000);
      //buy tokens
      await exchange
        .connect(addr1)
        .buyTokens(cardano.address, addr1.address, ownerOfCardano.address, {
          value: ethers.utils.parseEther("0.0000000000000045", "ether"),
        });
      await exchange
        .connect(addr2)
        .buyTokens(zilliqa.address, addr2.address, ownerOfZilliqa.address, {
          value: ethers.utils.parseEther("0.0000000000000045", "ether"),
        });
      // approve
      await cardano.connect(addr1).approve(exchange.address, 98);
      await zilliqa.connect(addr2).approve(exchange.address, 61);
      expect(await cardano.allowance(addr1.address, exchange.address)).to.eq(
        98
      );
      expect(await zilliqa.allowance(addr2.address, exchange.address)).to.eq(
        61
      );
      //create swap
      await exchange.connect(addr1).createSwapOrder(0, 2, 98, 25);
      expect(await exchange.getUserSwapOrdersCount(addr1.address)).to.eq(1);
      //swap
      await exchange.connect(addr2).swap(0, 0, 2, 98);
      expect(await cardano.balanceOf(addr2.address)).to.eq(98);
      expect(await zilliqa.balanceOf(addr1.address)).to.eq(61);
      console.log(
        "balance: ",
        await ethers.provider.getBalance(exchange.address)
      );
    });
  });
});

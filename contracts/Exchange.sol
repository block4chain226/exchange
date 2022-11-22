// SPDX-License-Identifier: WTF

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Cardano is ERC20, Ownable{
    event Payment(address from, uint amount, uint time);
    address payable public  cardanoOwner;
    constructor() ERC20("Cardano", "ADA"){
        cardanoOwner = payable(msg.sender);
        _mint(cardanoOwner, 100000000000000000);
    }

    function mint(address to, uint amount) public {
        _mint(to, amount);
    }
    receive() external payable{
        emit Payment(msg.sender, msg.value, block.timestamp);
    }

    function get()public view returns(uint){
        return cardanoOwner.balance;
    }

    function withdraw() public payable onlyOwner{
        cardanoOwner.transfer(address(this).balance);
    }
}

    contract Tether is ERC20, Ownable{
    event Payment(address from, uint amount, uint time);
    address payable public  tetherOwner;
    constructor() ERC20("Tether", "USDT"){
        tetherOwner = payable(msg.sender);
        _mint(tetherOwner, 100000000000000000);
    }

    function mint(address to, uint amount) public {
        _mint(to, amount);
    }

    receive() external payable{
       emit Payment(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() public payable onlyOwner{
        tetherOwner.transfer(address(this).balance);
    }
}

contract Zilliqa is ERC20, Ownable{
    event Payment(address from, uint amount, uint time);
    address payable public  zilOwner;
    constructor() ERC20("Zil", "ZIL"){
        zilOwner = payable(msg.sender);
        _mint(zilOwner, 100000000000000000);
    }

    function mint(address to, uint amount) public {
        _mint(to, amount);
    }

     receive() external payable{
       emit Payment(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() public payable onlyOwner{
        zilOwner.transfer(address(this).balance);
    }
}

contract Exchange is Ownable{

ERC20 public tether;
ERC20 public cardano;
ERC20 public zilliqa;
//cardano 0x5FbDB2315678afecb367f032d93F642f64180aa3
//teth 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
//zill 0x663F3ad617193148711d28f5334eE4Ed07016602

uint immutable fee;
// address payable owner;
struct User{address account; uint currenciesCount; uint swapOrdersCount;}
struct SwapOrder{uint swapOrderId; address owner; uint tokenToSellId; uint amount; uint rate; uint tokenToBuyId; bool isCompleted;}
uint private _swapOrderId;
User[] public _allUsers;
ERC20[] public _allCryptos;
SwapOrder[] private _allSwapOrders;

mapping(address=>User) public _users;
mapping(address=>bool) public _usersBase;
//address=>tokenId=>amount
mapping(address=>mapping(uint=>SwapOrder)) _userSwapOrders;
mapping(address=>mapping(uint=>uint)) _userTokensAmount;
mapping(ERC20=>uint) _tokensRate;
mapping(ERC20=>uint) _tokenToId;
mapping(uint=>ERC20) _idToToken;

event NewUser(address account, uint date);
event BoughtToken(address buyer, uint amount, uint rate, uint date);
event SellToken(address seller, uint amount, uint rate, uint date);
event SwapCreated(address owner, uint tokenToSellId, uint tokenToBuyId, uint amount, uint rate, uint date);
event Swap(address seller, uint sellTokensId,uint sellTokensAmount, address buyer, uint buyTokensId, uint buyTokensAmount, uint sellTokensRate, uint date);

constructor(ERC20 _cardano, ERC20 _tether, ERC20 _zilliqa){
    // owner = payable(msg.sender);
    fee = 100 wei;
    cardano = _cardano;
    tether = _tether;
    zilliqa = _zilliqa;
    _allCryptos.push(cardano);
    _allCryptos.push(tether);
    _allCryptos.push(zilliqa);
    for(uint i; i<_allCryptos.length; i++){
        _tokenToId[_allCryptos[i]] = i;
        _idToToken[i] = _allCryptos[i];
    }
    _tokensRate[tether] = 20;
    _tokensRate[cardano] = 20;
    _tokensRate[zilliqa] = 40;
}

///////////////////////////////User
function newUser() public returns(bool){
    require(msg.sender!=address(0), "not right account address");
    require(!_userExists(msg.sender), "user already exists");
    User memory _newUser = User(msg.sender, 0, 0);
    _allUsers.push(_newUser);
    _users[msg.sender] = _newUser;
    _usersBase[msg.sender] = true;
    emit NewUser(msg.sender, block.timestamp);
    return true;
}

function getUserSwapOrdersCount(address account) public view returns(uint){
    return _users[account].swapOrdersCount;
}

function getUserCurrenciesCount(address account) public view returns(uint){
    User memory currentUser = _users[account];
    return currentUser.currenciesCount;
}

function getUserTokenAmount(address account, uint index) public view returns(uint){
    require(_userExists(account));
    return _userTokensAmount[account][index];
}

function _userExists(address account) public view returns(bool){
    return _usersBase[account];
}

//////////////////////////////////Swap
function createSwapOrder(uint tokenToSellId, uint tokenToBuyId, uint amount, uint rate) public payable {
     require(_userExists(msg.sender), "not authorized");
     require(msg.value==fee, "you have not enough funds to pay fee(100 wei)");
     ERC20 tokenToSell = _idToToken[tokenToSellId];
     ERC20 tokenToBuy = _idToToken[tokenToBuyId];
     require(address(tokenToSell)!=address(0), "token does not exists");
     require(address(tokenToBuy)!=address(0), "token does not exists");
     require(amount>0, "amount must be more than 0");
     require(tokenToSell.balanceOf(msg.sender)>=amount, "you have not enough tokens");
     SwapOrder memory newOrder = SwapOrder(_swapOrderId, msg.sender, tokenToSellId, amount, rate, tokenToBuyId, false);
     User storage currentUser = _users[msg.sender]; 
     _userSwapOrders[msg.sender][currentUser.swapOrdersCount] = newOrder;
     _allSwapOrders.push(newOrder);
     currentUser.swapOrdersCount++;
     _swapOrderId++;
     emit SwapCreated(msg.sender, tokenToSellId, tokenToBuyId, amount, rate, block.timestamp);
}

function swap(uint swapOrderId, uint tokenToSellId, uint tokenToBuyId, uint amount) public payable {
    require(msg.value==fee, "you have not enough funds to pay fee(100 wei)");
    ERC20 tokenToSell = _idToToken[tokenToSellId];
    ERC20 tokenToBuy = _idToToken[tokenToBuyId];
    require(address(tokenToSell)!=address(0), "token does not exists");
    require(address(tokenToBuy)!=address(0), "token does not exists");
    require(_userExists(msg.sender), "not authorized");
    SwapOrder storage currentSwapOrder = _allSwapOrders[swapOrderId]; 
    uint tokensToBuyAmount = getTokensToBuyAmount(tokenToBuy, amount, currentSwapOrder.rate);
    require(tokenToBuy.allowance(msg.sender, address(this))>=tokensToBuyAmount, "not enough allowance");
    require(tokenToSell.allowance(currentSwapOrder.owner, address(this))>=amount, "not enough allowance");
    //owner
    tokenToSell.transferFrom(currentSwapOrder.owner, msg.sender, amount);
    _decreaseUserTokensAmount(tokenToSell, currentSwapOrder.owner, amount);
    _increaseUserTokensAmount(tokenToBuy, currentSwapOrder.owner, tokensToBuyAmount);
    _decrementUserCurrenciesAmount(tokenToSell, currentSwapOrder.owner);
    _incrementUserCurrenciesAmount(tokenToBuy, currentSwapOrder.owner);
     //buyer
    tokenToBuy.transferFrom(msg.sender, currentSwapOrder.owner, tokensToBuyAmount);
   _decreaseUserTokensAmount(tokenToBuy, msg.sender, tokensToBuyAmount);
   _increaseUserTokensAmount(tokenToSell, msg.sender, amount);
   _decrementUserCurrenciesAmount(tokenToBuy, msg.sender);
   _incrementUserCurrenciesAmount(tokenToSell, msg.sender);
    currentSwapOrder.isCompleted = true;
    emit Swap(currentSwapOrder.owner, tokenToSellId, amount, msg.sender, tokenToBuyId, tokensToBuyAmount, currentSwapOrder.rate, block.timestamp);
}

function _increaseUserTokensAmount(ERC20 token, address account, uint tokensAmount) internal {
    uint tokenId = getTokenIdByToken(token);
    _userTokensAmount[account][tokenId] += tokensAmount;
}

function _decreaseUserTokensAmount(ERC20 token, address account, uint tokensAmount) internal {
    uint tokenId = getTokenIdByToken(token);
    _userTokensAmount[account][tokenId] -= tokensAmount;
}

function _incrementUserCurrenciesAmount(ERC20 token, address account) internal {
     User storage  currentUser = _users[account];
     uint amountOfToken = token.balanceOf(account);
     //if before buing balance of token==0 we increment
     amountOfToken == 0 ? currentUser.currenciesCount++ : currentUser.currenciesCount;
}

function _decrementUserCurrenciesAmount(ERC20 token, address account) internal {
     User storage  currentUser = _users[account];
     uint amountOfToken = token.balanceOf(account);
     //if after selling balance of token==0 we decrement
     amountOfToken == 0 ? currentUser.currenciesCount-- : currentUser.currenciesCount;
}

function getSwipeOrder(address account, uint index) public view returns(SwapOrder memory){
    return _userSwapOrders[account][index];
}

//////////////////////////////////Buy tokens
function buyTokens(ERC20 token, address buyer, address tokensSeller) public payable returns(bool){
    uint amountTokens;
    uint weiToReturnToBuyer;
    uint amountOfWei = msg.value;
    _validateBeforePurchase(msg.sender, amountOfWei);
    (amountTokens, weiToReturnToBuyer) = _getTokensAmount(token, amountOfWei);
    bool result = _purchaseProcess(buyer, amountTokens, token,  tokensSeller);
    require(result, "tokens was not sent");
    //update buyer currenciesCount
    _incrementUserCurrenciesAmount(token, buyer);
    //update user tokensAmount
    _increaseUserTokensAmount(token, buyer, amountTokens);
    //if count of tokens will not integer, difference of wei will be returned to buyer
    if(weiToReturnToBuyer!=0){
        payable(buyer).transfer(weiToReturnToBuyer);
        amountOfWei-=weiToReturnToBuyer;
    }
    _refund(amountOfWei - fee, token);
    // _withdrawMoney(fee);
    emit BoughtToken(msg.sender, amountTokens, _tokensRate[token], block.timestamp);
    return true;
}

function _purchaseProcess(address to, uint tokensAmount, ERC20 token, address  tokensSeller) internal returns(bool){
    require(address(token)!=address(0), "token does not exists");
    require(tokensAmount>0, "you cant buy 0 tokens");
    token.transferFrom(tokensSeller, to, tokensAmount);
    return true;
}

function _validateBeforePurchase(address buyer , uint weiAmount) public view {
    require(_userExists(buyer), "user does not exist");
    require(buyer!=address(0), "address doesn't exists");
    require(weiAmount>0, "not enough funds");
    require(weiAmount>fee*2, "you need to pay at least 200 wei");
}

/////////////////////////////////Sell tokens
function sellTokens(ERC20 token, uint amount) public returns(bool){
    uint tokensCosts = getTotalSellTokensCosts(token, amount);
    _validateBeforeSell(token, msg.sender, amount, tokensCosts);
    bool result = _sellProcess(amount, token);
    require(result, "tokens were not sold");
    //update buyer currenciesCount
    _decrementUserCurrenciesAmount(token, msg.sender);
    //update user tokensAmount
    _decreaseUserTokensAmount(token, msg.sender, amount);
    //pay to owner of tokens
    payable(msg.sender).transfer(tokensCosts-fee);
    emit SellToken(msg.sender, amount, _tokensRate[token], block.timestamp);
    return true;
}

function _sellProcess(uint tokensAmount, ERC20 token) internal returns(bool){
    require(address(token)!=address(0), "token does not exists");
    token.transferFrom(msg.sender, address(this), tokensAmount);
    return true;
}

function _validateBeforeSell(ERC20 token, address seller, uint amount, uint tokensCosts) public view {
    require(_userExists(seller), "user does not exist");
    require(address(this).balance>=tokensCosts, "contract has not enough funds to pay for tokens");
    require(amount>0, "you can't sell 0 tokens");
    require(token.balanceOf(seller)>=amount, "not enough tokens");
}

//////////////////////////////Tokens functions
function _getTokensAmount(ERC20 token, uint weiAmount) internal view returns(uint tokensAmount, uint weiToReturnToBuyer){
    require(weiAmount>0, "you didn't pay");
    uint weiWithoutFee = weiAmount - fee;
    tokensAmount = weiWithoutFee / _tokensRate[token];
    uint weiAmountForTokens = tokensAmount * _tokensRate[token];
    weiToReturnToBuyer = weiWithoutFee - weiAmountForTokens;
}

function getTotalSellTokensCosts(ERC20 token, uint amount) internal view returns(uint){
    require(amount>0, "you can't sell 0 tokens");
    return _tokensRate[token] * amount;
}

function getTokenById(uint _id) public view returns(ERC20){
    return _idToToken[_id];
}

function getTokenIdByToken(ERC20 _token) public view returns(uint){
    return _tokenToId[_token];
}

function getTokensToBuyAmount(ERC20 tokenToBuy, uint tokensToSellAmount, uint tokenToSellRate) internal view returns(uint){
    uint totalPriceForSellTokens = tokenToSellRate * tokensToSellAmount;
    return totalPriceForSellTokens / _tokensRate[tokenToBuy];
}

function getTokenRate(ERC20 token) public view returns(uint){
    return _tokensRate[token];
}

//////////////////////////Withdraw operations
function _refund(uint amountOfWei, ERC20 token) public payable {
    payable(address(token)).transfer(amountOfWei);
}

function withdrawMoney() public onlyOwner() {
    payable(owner()).transfer(address(this).balance);
}

receive() external payable{
}
}
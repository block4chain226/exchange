// SPDX-License-Identifier: WTF

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Cardano is ERC20{
    event Payment(address from, uint amount, uint time);
    address payable public  cardanoOwner;
    constructor() ERC20("Cardano", "ADA"){
        cardanoOwner = payable(msg.sender);
        _mint(cardanoOwner, 100000000000000000);
    }
     function transferMoney(address payable account, uint amount)public payable{
        account.transfer(amount);
    }

    function mint(address to, uint amount) public {
        _mint(to, amount);
    }
    receive() external payable{
        emit Payment(msg.sender, msg.value, block.timestamp);
        cardanoOwner.transfer(address(this).balance);
    }
}

    contract Tether is ERC20{
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
        tetherOwner.transfer(address(this).balance);
    }
}

contract Zilliqa is ERC20{
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
        zilOwner.transfer(address(this).balance);
    }
}




contract Exchange{

}
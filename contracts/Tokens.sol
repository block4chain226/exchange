// SPDX-License-Identifier: WTF

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Tether is ERC20{
    event Payment(address from, uint amount, uint time);
    constructor() ERC20("Tether", "USDT"){
        _mint(address(this), 1000);
    }

    function mint(address to, uint amount) public {
        _mint(to, amount);
    }

    receive() external payable{
        emit Payment(msg.sender, msg.value, block.timestamp);
    }
}

// contract Zilliqa is ERC20{
//     constructor() ERC20("Zil", "ZIL"){}

//     function mint(address to, uint amount) public {
//         _mint(to, amount);
//     }
// }


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
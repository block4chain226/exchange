// SPDX-License-Identifier: WTF

pragma solidity >=0.7.0 <0.9.0;

interface IExchange{
function newUser() external returns(bool);
// function swap(address token1, address token2, uint amount) external returns(bool);
// function buyTokens(address token) external returns(bool);
// function sellToken(address token, uint amount) external returns(bool);
// function getCurrencies() external view returns(bytes[] memory);
// function setCurrencies(bytes[] memory _currencies) external;
}
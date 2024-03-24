// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 

/*
this Token should the first one deploy on blockchain.
*/

contract EToken is ERC20 
{
    // 20000000000
    constructor() ERC20("EToken", "EYT") 
    { 
        _mint(msg.sender, 2000000000 * 10**18);
    } 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol"; 

/*
this Token should the first one deploy on blockchain.
*/

contract CToken is ERC20 {
    constructor()
        ERC20("CTOKEN", "CTH", 18)
    {
        _mint(msg.sender, 100 * 10 ** uint256(18));
    }
}

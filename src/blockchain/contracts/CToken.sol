// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./openzeppelin/token/ERC20/ERC20.sol";

/*
this Token should the first one deploy on blockchain.
need save this address in website
*/

contract CToken is ERC20 {
    constructor()
    ERC20("Certicate Token", "CTH")
    {
        _mint(msg.sender, 100 * 10 ** 18);
    }
}

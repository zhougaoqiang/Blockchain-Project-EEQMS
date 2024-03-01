//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Withdrawable_Contract
{
    address owner;

    function withdraw() public
    {
        require(msg.sender == owner, "only owner able to withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
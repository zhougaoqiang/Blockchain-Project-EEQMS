//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISource
{
    function addAddress(address _verify, address _add) external;
    function hasAddress(address _add) external view returns (bool);
    function getAddress(address _verify, uint index) external view returns (address);
    function removeAddress(address _verify, address _add) external;
    function removeAddressByIndex(address _verify, uint index) external;
}
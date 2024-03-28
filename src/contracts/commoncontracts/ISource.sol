//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISource
{
    function addAddress(address _add) external;
    function hasAddress(address _add) external view returns (bool);
    function getAddress(uint index) external view returns (address);
    function removeAddress(address _add) external;
    function removeAddressByIndex(uint index) external;
}
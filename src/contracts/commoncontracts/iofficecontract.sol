//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// use to manager admin rights.
interface Interface_Office_Smart_Contract
{
    function transferOwnership(address newOwner) external;
    function isOwner() external view returns (bool);
    function isOfficer(address _add) external view returns (bool);
    function isOwnerOrOfficer(address _add) external view returns (bool);
    function addOfficer(address _add) external;
    function removeOfficer(address _add) external;
}
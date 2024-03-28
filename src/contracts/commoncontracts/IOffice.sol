//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// use to manager admin rights.
interface IOffice
{
    function transferOwnership(address _oriOwner, address _newOwner) external;
    function isOwner(address _owner) external view returns (bool);
    function isOfficer(address _add) external view returns (bool);
    function isOwnerOrOfficer(address _add) external view returns (bool);
    function addOfficer(address _owner, address _add) external;
    function removeOfficer(address _owner, address _add) external;
}
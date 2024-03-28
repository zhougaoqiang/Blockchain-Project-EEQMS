//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IOffice.sol";
// use to manage admin rights.
import "hardhat/console.sol";

contract Office is IOffice
{
    address owner;
    address[] officerList;

    constructor()
    {
        owner = msg.sender;
    }

    function transferOwnership(address _oriOwner, address _newOwner) external
    {
        require(owner == _oriOwner, "only owner can transfer ownership");
        owner = _newOwner;
    }

    function isOwner(address _owner) external view returns (bool)
    {
        if (owner == _owner)
            return true;
        else
            return false;
    }

    function findOfficerAddressIndexInArray(address _add) private view returns (uint)
    {
        for(uint i = 0; i < officerList.length; ++i)
        {
            if (_add == officerList[i])
                return i;
        }
        return type(uint).max;
    }

    function isOfficer(address _add) external view returns (bool)
    {
        uint index = findOfficerAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function isOwnerOrOfficer(address _add) external view returns (bool)
    {
        console.log("get Address => ", _add);
        if (owner == _add)
            return true;

        uint index = findOfficerAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function addOfficer(address _owner, address _add) external 
    {
        require(owner == _owner, "only owner can add officer");
        officerList.push(_add);
    }

    function removeOfficer(address _owner, address _add) external
    {
        require(owner == _owner, "only owner can remove officer");

        uint index = findOfficerAddressIndexInArray(_add);
        require(index != type(uint).max, "not exist");
        officerList[index] = officerList[officerList.length - 1];
        officerList.pop();
    }
}
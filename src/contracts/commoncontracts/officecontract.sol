//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// use to manage admin rights.
contract Office_Smart_Contract
{
    address owner;
    address[] officerList;

    constructor()
    {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external
    {
        require(owner == msg.sender, "only owner can transfer ownership");
        owner = newOwner;
    }

    function isOwner() external view returns (bool)
    {
        if (owner == msg.sender)
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
        if (owner == msg.sender)
            return true;

        uint index = findOfficerAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function addOfficer(address _add) external 
    {
        require(owner == msg.sender, "only owner can add officer");
        officerList.push(_add);
    }

    function removeOfficer(address _add) external
    {
        require(owner == msg.sender, "only owner can remove officer");

        uint index = findOfficerAddressIndexInArray(_add);
        require(index != type(uint).max, "not exist");
        officerList[index] = officerList[officerList.length - 1];
        officerList.pop();
    }
}
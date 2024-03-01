//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Government_Office_Smart_Contract
{
    address[] officerList;

    constructor()
    {
        officerList.push(msg.sender);
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

    function isOfficer(address _add) private view returns (bool)
    {
        uint index = findOfficerAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function isAdmin(address _add) external view returns (bool)
    {
        return isOfficer(_add);
    }
    
    modifier onlyOfficer()
    {
        require(isOfficer(msg.sender), "only officers are allowed");
        _;
    }

    function addOfficer(address _add) public onlyOfficer
    {
        officerList.push(_add);
    }

    function removeOfficer(address _add) public onlyOfficer
    {
        uint index = findOfficerAddressIndexInArray(_add);
        require(index != type(uint).max, "not exist");
    
        officerList[index] = officerList[officerList.length - 1];
        officerList.pop();
    }
}
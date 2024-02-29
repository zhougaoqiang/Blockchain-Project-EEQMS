//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

contract School_Office_Smart_Contract
{
    address public owner; //gov
    address[] private officers; //shcool admins
    School_Info public schoolInfo;

    constructor(School_Info memory _schoolInfo)
    {
        owner = msg.sender;
        schoolInfo = _schoolInfo;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    modifier onlyOwnerOrOfficer()
    {
        require(msg.sender == owner || isOfficer(msg.sender), "only onwer or officer allowed");
        _;
    }

    function isAdmin() external view returns (bool)
    {
        if (msg.sender == owner || isOfficer(msg.sender))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    function isOfficer(address _add) private view returns (bool)
    {
        for (uint i = 0; i < officers.length; ++i)
        {
            if (officers[i] == _add)
            {
                return true;
            }
        }
        return false;
    }

    function transferOwnership(address _newOwner) external onlyOwner
    {
        owner = _newOwner;
    }

    function addOfficer(address _newOfficer) external onlyOwner
    {
        require(!isOfficer(_newOfficer), "This officer is alreay an officer");
        officers.push(_newOfficer);   
    }
    
    function findOfficerIndex(address _officer) private view returns (uint)
    {
        for (uint i = 0; i < officers.length; ++i)
        {
            if (officers[i] == _officer)
                return i;
        }
        return type(uint).max; //return a invalid value if not found;
    }

    function removeOfficer(address _officer) external onlyOwner
    {
        uint officerIndex = findOfficerIndex(_officer);
        require(officerIndex != type(uint).max, "officer not in list");

        //because solidity only support pop in array. move last available address instead;
        officers[officerIndex] = officers[officers.length - 1];
        officers.pop();
    }

    function getSchoolInfo() external view returns (School_Info memory)
    {
        return schoolInfo;
    }

    function updateSchoolInfo(School_Info memory _schoolInfo) external onlyOwner
    {
        schoolInfo = _schoolInfo;
    }                                                         
}

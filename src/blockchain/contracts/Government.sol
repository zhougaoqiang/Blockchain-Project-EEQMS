//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IGovernment.sol";

contract Government is IGovernment
{   
    //default is false;
    address owner;
    mapping(address => bool) private adminList;
    mapping(address => bool) private registeredPersons;
    mapping(address => bool) private registeredCompanies;
    mapping(address => bool) private registeredSchools;

    constructor()
    {
        owner = msg.sender;
        adminList[msg.sender] = true;
    }

    modifier onlyOwner()
    {
        require(owner == msg.sender, "only goverment admin is allowed");
        _;
    }

    modifier onlyAdmin()
    {
        require(owner == msg.sender || adminList[msg.sender] == true, "only goverment admin is allowed");
        _;
    } 

    function addAdmin(address _add) public onlyOwner()
    {
        adminList[_add] = true;
    }

    function removeAdmin(address _add) public onlyOwner()
    {
        adminList[_add] = false;
    }

    function isRegisterCompany(address _add) external override view returns (bool)
    {
        return registeredCompanies[_add];
    }

    function registerCompany(address _add) public onlyAdmin()
    {
        registeredCompanies[_add] = true;
    }

    function isRegisterSchool(address _add) external override view returns (bool)
    {
        return registeredSchools[_add];
    }

    function registerSchool(address _add) public onlyAdmin()
    {
        registeredSchools[_add] = true;
    }

    function isRegisterPerson(address _add) external override view returns (bool)
    {
        return registeredPersons[_add];
    }

    function registerPerson(address _add) public onlyAdmin()
    {
        registeredPersons[_add] = true;
    }
}

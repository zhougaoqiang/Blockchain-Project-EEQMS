//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IGovernment.sol";
import "./openzeppelin/token/ERC20/IERC20.sol";

contract Government is IGovernment
{   
    //default is false;
    address owner;
    mapping(address => bool) private adminList;
    mapping(address => bool) private registeredPersons;
    mapping(address => bool) private registeredCompanies;
    mapping(address => bool) private registeredSchools;
    IERC20 erc20;

    constructor(address _eth)
    {
        owner = msg.sender;
        adminList[msg.sender] = true;
        erc20 = IERC20(_eth);
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
        erc20.approve(_add, 1*10**18);
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

    function getBanlance() public view returns (uint256)
    {
        return erc20.balanceOf(owner);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/iofficecontract.sol";
import "../commoncontracts/isourcecontract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 


/*
the government smart contract should create before software release and after ERC20 deployed

NOTE: THE GOVERNMENT ADDRESS AND ERC20 ADDRESS SHOULD BE FIXED IN WEBSITE

govenment contract deploy sequence.
1. deploy office contract
2. deploy company source contract (need office contract address)
3. deploy school source contract (need office contract address)
4. deploy person source contract (need office contract address)
5. deploy government smart contract with company, school, person source contract, and ERC20 also.

*/
contract Government_Smart_Contract //this contract address will publish to all
{
    Interface_Office_Smart_Contract officeContract;
    Interface_Source_Smart_Contract companyContracts;
    Interface_Source_Smart_Contract schoolContracts;
    Interface_Source_Smart_Contract personContracts;
    IERC20 public eToken;
    

    constructor(address _off, address _com, address _sch, address _per, address _token)
    {
        officeContract = Interface_Office_Smart_Contract(_off);
        companyContracts = Interface_Source_Smart_Contract(_com);
        schoolContracts = Interface_Source_Smart_Contract(_sch);
        personContracts = Interface_Source_Smart_Contract(_per);
        eToken = IERC20(_token);
    }

    modifier onlyAdmin()
    {
        require(officeContract.isOwnerOrOfficer(msg.sender), "only admin is allowed");
        _;
    }

    function isRegisterSchool(address _add) external view returns (bool)
    {
        return schoolContracts.hasAddress(_add);
    }

    function isRegisterCompany(address _add) external view returns (bool)
    {
        return companyContracts.hasAddress(_add);
    }
    
    function isRegisterPerson(address _add) external view returns (bool)
    {
        return personContracts.hasAddress(_add);
    }

    function registerSchool(address _add) public onlyAdmin
    {
        require(!schoolContracts.hasAddress(_add), "registered already");
        schoolContracts.addAddress(_add);
    }

    function registerCompany(address _add) public onlyAdmin
    {
        require(!companyContracts.hasAddress(_add), "registered already");

        companyContracts.addAddress(_add);
        eToken.transfer(_add, 100 * 10**18);
    }

    function registerPerson(address _add) public onlyAdmin
    {
        require(!personContracts.hasAddress(_add), "registered already");
        personContracts.addAddress(_add);
    }
}

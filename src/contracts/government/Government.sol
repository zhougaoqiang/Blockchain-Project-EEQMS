//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IGovernment.sol";
import "../commoncontracts/IOffice.sol";
import "../commoncontracts/ISource.sol";
import "../TOKEN/IERC20.sol"; 
import "hardhat/console.sol";


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
contract Government is IGovernment 
{
    IOffice officeContract;
    ISource companyContracts;
    ISource schoolContracts;
    ISource personContracts;
    IERC20 public eToken;
    

    constructor(address _off, address _com, address _sch, address _per, address _token)
    {
        officeContract = IOffice(_off);
        companyContracts = ISource(_com);
        schoolContracts = ISource(_sch);
        personContracts = ISource(_per);
        eToken = IERC20(_token);
    }

    modifier onlyAdmin(address _add)
    {
        console.log("onlyAdmin get Address => ", _add);
        require(officeContract.isOwnerOrOfficer(_add), "only admin is allowed");
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

    function registerSchool(address _verify, address _add) public onlyAdmin(_verify)
    {
        require(!schoolContracts.hasAddress(_add), "registered already");
        schoolContracts.addAddress(msg.sender, _add);
    }

    function registerCompany(address _verify, address _add) public onlyAdmin(_verify)
    {
        console.log("registerCompany get Address => ", msg.sender);
        require(!companyContracts.hasAddress(_add), "registered already");
        companyContracts.addAddress(msg.sender, _add);
        // eToken.transfer(_add, 100 * 10**18);
    }

    function registerPerson(address _verify, address _add) public onlyAdmin(_verify)
    {
        require(!personContracts.hasAddress(_add), "registered already");
        personContracts.addAddress(msg.sender, _add);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/otherdefinition.sol";
import "./interfaces/schooldefinition.sol";
import "./governmentofficecontract.sol";
import "./governmentsourcecontract.sol";

contract Government_Smart_Contract //this contract address will publish to all
{
    Government_Office_Smart_Contract officeContract;
    Government_Source_Smart_Contract sourceContract;

    constructor()
    {
        officeContract = new Government_Office_Smart_Contract();
        sourceContract = new Government_Source_Smart_Contract(address(officeContract));
    }

    modifier onlyAdmin()
    {
        require(officeContract.isAdmin(msg.sender), "only admin is allowed");
        _;
    }

    function isRegisterSchool(address _add) external view returns (bool)
    {
        uint index = sourceContract.findSchoolAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function isRegisterCompany(address _add) external view returns (bool)
    {
        uint index = sourceContract.findCompanyAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }
}
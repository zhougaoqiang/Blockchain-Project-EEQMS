//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/governmentofficeinterface.sol";

contract Government_Source_Smart_Contract
{
    Interface_Government_Office_Smart_Contract officeContract;
    address[] private schoolContractAdds;
    address[] private companyContractAdds;
    address[] private personalContractAdds;

    constructor(address _officeAdd)
    {
        officeContract = Interface_Government_Office_Smart_Contract(_officeAdd);
    }

    modifier onlyAdmin()
    {
        require(officeContract.isAdmin(msg.sender), "only admin allowed");
        _;
    }

    function findSchoolAddressIndexInArray(address _add) public view onlyAdmin returns (uint)
    {
        for(uint i = 0; i < schoolContractAdds.length; ++i)
        {
            if (_add == schoolContractAdds[i])
                return i;
        }
        return type(uint).max;
    }

    function findCompanyAddressIndexInArray(address _add) public view onlyAdmin returns (uint)
    {
        for(uint i = 0; i < companyContractAdds.length; ++i)
        {
            if (_add == companyContractAdds[i])
                return i;
        }
        return type(uint).max;
    }

    function findPersonalAddressIndexInArray(address _add) public view onlyAdmin returns (uint)
    {
        for(uint i = 0; i < personalContractAdds.length; ++i)
        {
            if (_add == personalContractAdds[i])
                return i;
        }
        return type(uint).max;
    }

    function registerSchool(address _add) public onlyAdmin
    {
        schoolContractAdds.push(_add);
    }

    function registerCompany(address _add) public onlyAdmin
    {
        companyContractAdds.push(_add);
    }

    function registerPerson(address _add) public onlyAdmin
    {
        personalContractAdds.push(_add);
    }

    // function removeSchool(address _add) public onlyAdmin
    // {
    //     uint index = findSchoolAddressIndexInArray(_add);
    //     require(index != type(uint).max, "not in list");
    //     schoolContractAdds[index] = schoolContractAdds[schoolContractAdds.length - 1];
    //     schoolContractAdds.pop();
    // }

    // function removeCompany(address _add) public onlyAdmin
    // {
    //     uint index = findCompanyAddressIndexInArray(_add);
    //     require(index != type(uint).max, "not in list");
    //     companyContractAdds[index] = companyContractAdds[companyContractAdds.length - 1];
    //     companyContractAdds.pop();
    // }

    // function removePerson(address _add) public onlyAdmin
    // {
    //     uint index = findPersonalAddressIndexInArray(_add);
    //     require(index != type(uint).max, "not in list");
    //     personalContractAdds[index] = personalContractAdds[personalContractAdds.length - 1];
    //     personalContractAdds.pop();
    // }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/otherdefinition.sol";
import "./interfaces/schooldefinition.sol";
import "./interfaces/certificatesinterface.sol";

contract Peronal_Smart_Contract
{
    address owner;
    address[] private companyAdmins;
    address[] private certificateContracts;
    Personal_Info private personalInfo;
    Certificate_Info[] certificates;

    constructor(Personal_Info memory _personalInfo)
    {
        owner = msg.sender;
        personalInfo = _personalInfo;
    }

    modifier isOwner()
    {
        require(msg.sender == owner, "only owner allowed");
        _;
    }

    modifier onlyOwnerOrCompanyAdmin()
    {
        require(msg.sender == owner || isCompanyAdmin(msg.sender), "only Owner Or Company Admin");
        _;
    }

    function isCompanyAdmin(address admin) private view returns (bool)
    {
        for (uint i = 0; i < companyAdmins.length; ++i)
        {
            if (admin == companyAdmins[i])
                return true;
        }
        return false;
    }

    function addCompanyAdmins(address _admin) public isOwner
    {
        companyAdmins.push(_admin);
    }

    function removeAllAdmins() public isOwner
    {
        for(uint i = 0; i < companyAdmins.length; ++i)
        {
            companyAdmins.pop();
        }
    }

    function addCertiticateContract(address _add) public isOwner
    {
        certificateContracts.push(_add);
        Interface_Certificate_Smart_Contract certContract = Interface_Certificate_Smart_Contract(_add);
        certificates.push(certContract.getCertificate());
    }

    function getPersonalInfo() external view onlyOwnerOrCompanyAdmin returns (Personal_Info memory) 
    {
        return personalInfo;
    }

    function getAllCertificates() external view onlyOwnerOrCompanyAdmin returns (Certificate_Info[] memory)
    {
        return certificates;
    }

    function getCertificatesCounts() external view onlyOwnerOrCompanyAdmin returns (uint)
    {
        return certificates.length;
    }

    function getCertificateByIndex(uint _index) external view onlyOwnerOrCompanyAdmin returns (Certificate_Info memory)
    {
        require(_index < certificates.length, "This certificate is not exist");
        return certificates[_index];
    }

    function getCertificateAddressIndex(uint256 signature) private view returns (uint)
    {
        for(uint i = 0; i < certificates.length; ++i)
        {
            if (certificates[i].signature == signature)
                return i;
        }
        return type(uint).max; //return a invalid value if not found;
    }

    function getTranscript(Certificate_Info memory _cert) external view onlyOwnerOrCompanyAdmin returns (Transcript_Info memory)
    {
        uint index = getCertificateAddressIndex(_cert.signature);
        require(index != type(uint).max, "not find this certificate");

        Transcript_Info memory trans;
        trans.certificate = certificates[index];
        Interface_Certificate_Smart_Contract certContract = Interface_Certificate_Smart_Contract(certificateContracts[index]);
        trans.signature = certContract.getTranscript().signature;
        trans.courseList = new Course_Info[](certContract.getTranscript().courseList.length); 
        for(uint i = 0; i < certContract.getTranscript().courseList.length; ++i)
        {
            trans.courseList[i] = certContract.getTranscript().courseList[i];
        }
        return trans;
    }
}
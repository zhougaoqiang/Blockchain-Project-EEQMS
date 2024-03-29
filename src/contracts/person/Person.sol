//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/CommonDefinition.sol";
import "../commoncontracts/SchoolDefinition.sol";
import "../commoncontracts/IOffice.sol";
import "../commoncontracts/ISource.sol";
import "../school/ICertificate.sol";
import "./IPerson.sol";

/*
the person smart contract should create after software release

company contract deploy sequence.
1. deploy office contract
2. deploy source contract (need office address)
3. deploy person smart contract with office and source contract.

ADDITIONAL:
the website should add register page and login page.
register function should follow above deploy sequence.

login page need user provide company smart contract address. we can return error if cannot get anything.

*/


contract Person is IPerson
{
    IOffice officeContract;
    ISource certificateContracts;
    Personal_Info private personalInfo;
    Certificate_Info[] certificates;

    constructor(address _off, address _source)
    {
        officeContract = IOffice(_off);
        certificateContracts = ISource(_source);
    }

    modifier onlyOwner()
    {
        require(officeContract.isOwner(), "only owner allowed");
        _;
    }

    modifier onlyOwnerOrCompanyAdmin()
    {
        require(officeContract.isOwnerOrOfficer(msg.sender), "only Owner Or Company Admin");
        _;
    }

    function addCertiticateContract(address _add) public onlyOwner
    {
        certificateContracts.addAddress(_add);
        ICertificate certContract = ICertificate(_add);
        certificates.push(certContract.getCertificate());
    }

    function setPersonalInfo(Personal_Info memory _info) public onlyOwner
    {
        personalInfo = _info;
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
        ICertificate certContract = ICertificate(certificateContracts.getAddress(index));
        trans.signature = certContract.getTranscript().signature;
        trans.courseList = new Course_Info[](certContract.getTranscript().courseList.length); 
        for(uint i = 0; i < certContract.getTranscript().courseList.length; ++i)
        {
            trans.courseList[i] = certContract.getTranscript().courseList[i];
        }
        return trans;
    }
}
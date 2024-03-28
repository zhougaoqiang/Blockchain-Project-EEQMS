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

    modifier onlyOwner(address _add)
    {
        require(officeContract.isOwner(_add), "only owner allowed");
        _;
    }

    modifier onlyOwnerOrCompanyAdmin(address _add)
    {
        require(officeContract.isOwnerOrOfficer(_add), "only Owner Or Company Admin");
        _;
    }

    function acceptCertificateContract(address _add) public onlyOwner(msg.sender)
    {
        ICertificate cert = ICertificate(_add);
        cert.acceptedCertifcate(msg.sender, address(officeContract));
    }
    // before add certificate to self. please call acceptCertificateContract first. 
    function addCertificateContract(address _add) public onlyOwner(msg.sender)
    {
        certificateContracts.addAddress(msg.sender, _add); //add to contractsList
        ICertificate certContract = ICertificate(_add);
        certificates.push(certContract.getCertificate(msg.sender));
    }

    function setPersonalInfo(Personal_Info memory _info) public onlyOwner(msg.sender)
    {
        personalInfo = _info;
    }

    function getPersonalInfo(address _verify) external view onlyOwnerOrCompanyAdmin(_verify) returns (Personal_Info memory) 
    {
        return personalInfo;
    }

    function getAllCertificates(address _verify) external view onlyOwnerOrCompanyAdmin(_verify) returns (Certificate_Info[] memory)
    {
        return certificates;
    }

    function getCertificatesCounts(address _verify) external view onlyOwnerOrCompanyAdmin(_verify) returns (uint)
    {
        return certificates.length;
    }

    function getCertificateByIndex(address _verify, uint _index) external view onlyOwnerOrCompanyAdmin(_verify) returns (Certificate_Info memory)
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

    // the _verify must be the student itself,
    function getTranscript(address _verify, Certificate_Info memory _cert) external view onlyOwnerOrCompanyAdmin(_verify) returns (Transcript_Info memory)
    {
        uint index = getCertificateAddressIndex(_cert.signature);
        require(index != type(uint).max, "not find this certificate");

        Transcript_Info memory trans;
        trans.certificate = certificates[index];
        ICertificate certContract = ICertificate(certificateContracts.getAddress(_verify, index));
        trans.signature = certContract.getTranscript(_verify).signature;
        trans.courseList = new Course_Info[](certContract.getTranscript(_verify).courseList.length); 
        for(uint i = 0; i < certContract.getTranscript(_verify).courseList.length; ++i)
        {
            trans.courseList[i] = certContract.getTranscript(_verify).courseList[i];
        }
        return trans;
    }
}
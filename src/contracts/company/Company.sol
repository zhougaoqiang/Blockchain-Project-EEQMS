//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/IOffice.sol";
import "../commoncontracts/ISource.sol";
import "../commoncontracts/CommonDefinition.sol";
import "../person/IPerson.sol";
import "../school/ISchool.sol";
import "../government/IGovernment.sol";
import "../TOKEN/IERC20.sol";

/*
the company smart contract should create after software release

company contract deploy sequence.
1. deploy office contract
2. deploy staff source contract (need office contract address)
5. deploy company smart contract with office, staff(candidate) source contract, and ERC20 also.

ADDITIONAL:
the website should add register page and login page.
register function should follow above deploy sequence.

login page need user provide company smart contract address. we can return error if cannot get anything.

*/

contract Company
{
    IOffice officeContract;
    ISource staffContractSource;
    Company_Info public companyInfo;
    Personal_Info[] staffInfoList;
    address governmentAddress;
    IERC20 private tokenContract;

    constructor(address _govAdd, address _office, address _staffContractSource, address _token)
    {
        governmentAddress = _govAdd;
        officeContract = IOffice(_office);
        staffContractSource = ISource(_staffContractSource);
        tokenContract = IERC20(_token);
    }

    modifier isOwner()
    {
        require(officeContract.isOwner(), "only owner allowed");
        _;
    }

    modifier onlyOwnerOrCompanyAdmin()
    {
        require(officeContract.isOwnerOrOfficer(msg.sender), "only Owner Or Company Admin");
        _;
    }

    function setCompanyInfo(Company_Info memory _info) external isOwner
    {
        companyInfo = _info;
    }

    function getCompanyInfo() external view returns (Company_Info memory) 
    {
        return companyInfo;
    }

    function addStaff(Personal_Info memory _personalInfo, address staffContractAdd) external onlyOwnerOrCompanyAdmin
    {
        staffInfoList.push(_personalInfo);
        staffContractSource.addAddress(staffContractAdd);
    }

    function findStaffIndex(uint256 id) private view returns (uint)
    {
        for(uint i = 0; i < staffInfoList.length; ++i)
        {
            if (id == staffInfoList[i].id)
                return id;
        }

        return type(uint).max;
    }

    function removeStaff(uint256 _id) public onlyOwnerOrCompanyAdmin
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");

        staffInfoList[index] = staffInfoList[staffInfoList.length - 1];
        staffInfoList.pop();
        staffContractSource.removeAddressByIndex(index);
    }

    function getStaffCertifcates(uint256 _id) public view returns (Certificate_Info[] memory)
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");
        IPerson personContract = IPerson(staffContractSource.getAddress(index));
        uint noOfCerts = personContract.getCertificatesCounts();
        require (noOfCerts > 0, "No cert exist");

        return personContract.getAllCertificates();
    }

    function verifyStaffCertificate(uint256 _id, bool verifyTransAlso, Certificate_Info memory _cert) public returns (bool)
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");

        IGovernment gov = IGovernment(governmentAddress);
        if (!gov.isRegisterSchool(_cert.schoolInfo.schoolContractAddress))
        {
            return false;
        }
        
        ISchool schoolContract = ISchool(_cert.schoolInfo.schoolContractAddress);
        bool isOk = false;
        if (!verifyTransAlso) 
        {
            // 在UI中或通过直接与代币合约交互之前完成
            // tokenContract.approve(schoolContractAddress, amount);
            isOk = schoolContract.verifyGraduatedStudentCertificate(_cert);
        } 
        else 
        {
            // 在UI中或通过直接与代币合约交互之前完成
             // tokenContract.approve(schoolContractAddress, amount);
             IPerson personContract = IPerson(staffContractSource.getAddress(index));
             isOk = schoolContract.verifyGraduateStudentTranscript(personContract.getTranscript(_cert));
        }

        if (!isOk) 
            return false;
        else
            return true;
    }

    function verifyStaffAllCertificate(uint256 _id, bool verifyTransAlso) public returns (bool)
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");

        IPerson personContract = IPerson(staffContractSource.getAddress(index));
        uint noOfCerts = personContract.getCertificatesCounts();
        require (noOfCerts > 0, "No cert exist");

        for (uint i = 0; i < noOfCerts; ++i)
        {
            Certificate_Info memory cert = personContract.getCertificateByIndex(i);
            bool isOk = verifyStaffCertificate(_id, verifyTransAlso, cert);
            if (!isOk)
                return false;
        }
        return true;
    }
}
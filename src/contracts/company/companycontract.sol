//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/iofficecontract.sol";
import "../commoncontracts/isourcecontract.sol";
import "../commoncontracts/commondefinition.sol";
import "../person/ipersoncontract.sol";
import "../school/ischoolcontract.sol";
import "../government/igovernmentcontract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Company_Smart_Contract
{
    Interface_Office_Smart_Contract officeContract;
    Interface_Source_Smart_Contract staffContractSource;
    Company_Info public companyInfo;
    Personal_Info[] staffInfoList;
    address governmentAddress;
    IERC20 private tokenContract;

    constructor(address _govAdd, address _office, address _staffContractSource, address _token)
    {
        governmentAddress = _govAdd;
        officeContract = Interface_Office_Smart_Contract(_office);
        staffContractSource = Interface_Source_Smart_Contract(_staffContractSource);
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

    function removeStaff(uint256 _id) external onlyOwnerOrCompanyAdmin
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");

        staffInfoList[index] = staffInfoList[staffInfoList.length - 1];
        staffInfoList.pop();
        staffContractSource.removeAddressByIndex(index);
    }

    function verifyStaffCertificate(uint256 _id, bool verifyTransAlso) external returns (bool)
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");

        Interface_Peronal_Smart_Contract personContract = Interface_Peronal_Smart_Contract(staffContractSource.getAddress(index));
        uint noOfCerts = personContract.getCertificatesCounts();
        require (noOfCerts > 0, "No cert exist");

        for (uint i = 0; i < noOfCerts; ++i)
        {
            Certificate_Info memory cert = personContract.getCertificateByIndex(i);
            Interface_Government_Smart_Contract gov = Interface_Government_Smart_Contract(governmentAddress);
            if (!gov.isRegisterSchool(cert.schoolInfo.schoolContractAddress))
            {
                return false;
            }
            Interface_School_Smart_Contract schoolContract = Interface_School_Smart_Contract(cert.schoolInfo.schoolContractAddress);
            bool isOk = false;
            if (!verifyTransAlso) 
            {
                 // 在UI中或通过直接与代币合约交互之前完成
                 // tokenContract.approve(schoolContractAddress, amount);
                isOk = schoolContract.verifyGraduatedStudentCertificate(cert);
            } 
            else 
            {
                // 在UI中或通过直接与代币合约交互之前完成
                // tokenContract.approve(schoolContractAddress, amount);
                isOk = schoolContract.verifyGraduateStudentTranscript(personContract.getTranscript(cert));
            }

            if (!isOk)
            {
                return false;
            }
        }
        return true;
    }
}
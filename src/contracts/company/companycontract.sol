//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/iofficecontract.sol";
import "../commoncontracts/isourcecontract.sol";
import "../commoncontracts/commondefinition.sol";
import "../person/ipersoncontract.sol";
import "../school/ischoolcontract.sol";
import "../government/igovernmentcontract.sol";

contract Company_Smart_Contract
{
    Interface_Office_Smart_Contract officeContract;
    Interface_Source_Smart_Contract staffContractSource;
    Company_Info public companyInfo;
    Personal_Info[] staffInfoList;
    address governmentAddress;

    constructor(address _govAdd, address _office, address _staffContractSource)
    {
        governmentAddress = _govAdd;
        officeContract = Interface_Office_Smart_Contract(_office);
        staffContractSource = Interface_Source_Smart_Contract(_staffContractSource);
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
            uint verificationFee;
            if (!verifyTransAlso) 
            {
                verificationFee = schoolContract.getVerifyFee();
                (bool success, bytes memory data) = address(schoolContract).call{value: verificationFee}(
                    abi.encodeWithSignature("verifyGraduatedStudentCertificate((uint256,Student_Info,School_Info,string))", cert));
                require(success, "Verification failed");
                isOk = abi.decode(data, (bool));
            } 
            else 
            {
                verificationFee = schoolContract.getVerifyFee();
                (bool success, bytes memory data) = address(schoolContract).call{value: verificationFee}(
                    abi.encodeWithSignature("verifyGraduateStudentTranscript((Certificate_Info,Transcript_Info))", personContract.getTranscript(cert)));
                require(success, "Verification failed");
                isOk = abi.decode(data, (bool));
            }

            if (!isOk)
            {
                return false;
            }
        }
        return true;
    }
}
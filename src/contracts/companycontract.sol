//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/otherdefinition.sol";
import "./interfaces/schooldefinition.sol";
import "./interfaces/certificatesinterface.sol";
import "./interfaces/personalinterface.sol";
import "./interfaces/schoolinterface.sol";
import "./interfaces/schoolverificationverviceinterface.sol";

contract Company_Smart_Contract
{
    address owner;
    address[] private companyAdmins;
    Company_Info public companyInfo;
    address[] staffContractAddressList;
    Personal_Info[] staffInfoList;

    constructor(Company_Info memory _companyInfo)
    {
        companyInfo = _companyInfo;
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

    function transferOwnership(address newOwner) external isOwner
    {
        owner = newOwner;
    }

    function addCompanyAdmins(address _admin) external isOwner
    {
        companyAdmins.push(_admin);
    }

    function removeAllAdmins() external isOwner
    {
        for(uint i = 0; i < companyAdmins.length; ++i)
        {
            companyAdmins.pop();
        }
    }

    function getCompanyInfo() external view onlyOwnerOrCompanyAdmin returns (Company_Info memory) 
    {
        return companyInfo;
    }

    function addStaff(Personal_Info memory _personalInfo, address staffContractAdd) external onlyOwnerOrCompanyAdmin
    {
        staffInfoList.push(_personalInfo);
        staffContractAddressList.push(staffContractAdd);
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
        staffContractAddressList[index] = staffContractAddressList[staffContractAddressList.length - 1];
        staffContractAddressList.pop();
    }

    function verifyStaffCertificate(uint256 _id, bool verifyTransAlso) external payable returns (bool)
    {
        uint index = findStaffIndex(_id);
        require(index != type(uint).max, "not find thie staff");

        Interface_Peronal_Smart_Contract personContract = Interface_Peronal_Smart_Contract(staffContractAddressList[index]);
        uint noOfCerts = personContract.getCertificatesCounts();
        require (noOfCerts > 0, "No cert exist");

        for (uint i = 0; i < noOfCerts; ++i)
        {
            Certificate_Info memory cert = personContract.getCertificateByIndex(i);
            Interface_School_Smart_Contract schoolContract = Interface_School_Smart_Contract(cert.schoolInfo.schoolContractAddress);
            Interface_School_Verification_Service_Smart_Contract verifyContact = Interface_School_Verification_Service_Smart_Contract(schoolContract.getSchoolVerificationServiceContract());
            bool isOk = false;
            uint verificationFee;
            if (!verifyTransAlso) 
            {
                verificationFee = verifyContact.getCertificateFee();
                (bool success, bytes memory data) = address(verifyContact).call{value: verificationFee}(
                    abi.encodeWithSignature("verifyGraduatedStudentCertificate((uint256,Student_Info,School_Info,string))", cert));
                require(success, "Verification failed");
                isOk = abi.decode(data, (bool));
            } 
            else 
            {
                verificationFee = verifyContact.getTranscationFee();
                (bool success, bytes memory data) = address(verifyContact).call{value: verificationFee}(
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
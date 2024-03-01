//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/schooldefinition.sol";
import "./certificatescontract.sol";
import "./schoolofficecontract.sol";
import "./schoolsourcecontract.sol";
import "./schoolverificationvervicecontract.sol";
import "./library/schoolhashlib.sol";

contract School_Smart_Contract
{
    using Hash_Lib for * ;
    School_Office_Smart_Contract officeContract;
    School_Source_Smart_Contract sourceContract;
    School_Verification_Service_Smart_Contract verifyContract;

    constructor(School_Info memory _schoolInfo)
    {
        _schoolInfo.schoolContractAddress = address(this);
        officeContract = new School_Office_Smart_Contract(_schoolInfo);
        sourceContract = new School_Source_Smart_Contract(address(officeContract));
        verifyContract = new School_Verification_Service_Smart_Contract(address(officeContract), address(sourceContract));
    }

    modifier isAdmin()
    {
        require(officeContract.isAdmin());
        _;
    }

    function getSchoolOfficeContract() external view returns (address)
    {
        return address(officeContract);
    }

    function getSchoolSourceContract() external view returns (address)
    {
        return address(sourceContract);
    }

    function getSchoolVerificationServiceContract() external view returns (address)
    {
        return address(verifyContract);
    }

    function studentAdmission(Student_Info memory _stdInfo) public isAdmin
    {
        sourceContract.newStudent(_stdInfo, officeContract.getSchoolInfo());
    }

    //core function: issue student certificate contract
    function studentGradutaion(uint256 _studId, address _studAdd) public isAdmin returns (address)
    {
        require (sourceContract.isCurrentStudent(_studId) && sourceContract.checkGraduateRequirement(_studId), "No current student, or not match graduate requirement");
        
        Certificate_Info memory cert =  sourceContract.getCurrentStudentCertificate(_studId);
        cert.signature = Hash_Lib.hashCertificate(cert);
        uint256 transSig = Hash_Lib.hashTranscript(sourceContract.getCurrentStudentTranscript(_studId), true);
        Certificate_Smart_Contract newStudentContract = new Certificate_Smart_Contract(
                                            _studAdd,cert, transSig,
                                            sourceContract.getCurrentStudentTranscript(_studId).courseList);
        
        sourceContract.addGraduatedStudent(_studId, address(newStudentContract));
        sourceContract.removeStudent(_studId);
        return address(newStudentContract);
    }
}

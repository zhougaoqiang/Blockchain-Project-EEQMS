//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";
import "./certificatescontract.sol";
import "./schoolofficecontract.sol";
import "./schoolsourcecontract.sol";

contract School_Smart_Contract
{
    School_Office_Smart_Contract officeContract;
    School_Source_Smart_Contract sourceContract;

    constructor(School_Info memory _schoolInfo)
    {
        officeContract = new School_Office_Smart_Contract(_schoolInfo);
        sourceContract = new School_Source_Smart_Contract(address(officeContract));
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

    function studentAdmission(Student_Info memory _stdInfo) public isAdmin
    {
        sourceContract.newStudent(_stdInfo, officeContract.getSchoolInfo());
    }

    //core function: issue student certificate contract
    function studentGradutaion(uint256 _studId, address _studAdd) public isAdmin returns (address)
    {
        require (sourceContract.isCurrentStudent(_studId) && sourceContract.checkGraduateRequirement(_studId), "No current student, or not match graduate requirement");
        
        Certificate_Smart_Contract newStudentContract = new Certificate_Smart_Contract(
                                            _studAdd,
                                            sourceContract.getCurrentStudentCertificate(_studId), 
                                            sourceContract.getCurrentStudentTranscript(_studId).signature,
                                            sourceContract.getCurrentStudentTranscript(_studId).courseList);
        
        sourceContract.addGraduatedStudent(_studId, address(newStudentContract));
        sourceContract.removeStudent(_studId);
        return address(newStudentContract);
    }
}

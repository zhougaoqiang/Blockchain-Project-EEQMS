//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/schooldefinition.sol";
import "../commoncontracts/iofficecontract.sol";

contract School_Source_Smart_Contract
{
    mapping(uint256 => Transcript_Info) private studsTrans;
    uint256[] private curStudArray;
    mapping(uint256 => address) private graduatedStudentInfo; //studentId => studentContractAddress
    Interface_Office_Smart_Contract officeContract;

    constructor(address officeContractAddress)
    {
        officeContract = Interface_Office_Smart_Contract(officeContractAddress);
    }
    modifier onlyAdmin()
    {
        require(officeContract.isOwnerOrOfficer(msg.sender));
        _;
    }

    function addGraduatedStudent(uint256 id, address _add) external onlyAdmin
    {
        graduatedStudentInfo[id] = _add;
    }

    function getGraduatedStudent(uint256 id) external view onlyAdmin returns (address) 
    {
        return graduatedStudentInfo[id];
    }

    function newStudent(Student_Info memory _stdInfo, School_Info memory _schoolInfo) external onlyAdmin
    {
        uint256 studentId = _stdInfo.id; //school must create a unqiure id for student first;
        Certificate_Info memory cert;
        cert.schoolInfo = _schoolInfo;
        cert.honor = EHonor.None;
        cert.status = EStudyStatus.InProgress;
        cert.admissionTimestamp = block.timestamp;
        cert.studentDetails = _stdInfo;
        curStudArray.push(studentId);
        studsTrans[studentId].certificate = cert;
    }

    function addCurrentStudentCourseInfo(uint256 _studId, Course_Info memory _courseList) external onlyAdmin
    {
        studsTrans[_studId].courseList.push(_courseList);
    }

    function getCurrentStudentCertificate(uint256 _stuId) external view onlyAdmin returns (Certificate_Info memory)
    {
        return studsTrans[_stuId].certificate;
    }

    function getCurrentStudentTranscript(uint256 _stuId) external view onlyAdmin returns (Transcript_Info memory)
    {
        return studsTrans[_stuId];
    }
    
    function isCurrentStudent(uint256 _studId) external view onlyAdmin returns (bool)
    {
        return isCurStudent(_studId);
    }

    function isCurStudent(uint256 _stuId) private view onlyAdmin returns (bool)
    {
        for (uint i = 0; i < curStudArray.length; ++i)
        {
            if (curStudArray[i] == _stuId)
            {
                return true;
            }
        }
        return false;
    }

    function updateStudentCertificate(Certificate_Info memory _cert) onlyAdmin external
    {
        uint256 stuId = _cert.studentDetails.id;
        require (isCurStudent(stuId), "No current student, should admission first");

        studsTrans[stuId].certificate = _cert;
    }

    function setStudentTranscript(Transcript_Info memory _trans) onlyAdmin external
    {
        uint256 stuId = _trans.certificate.studentDetails.id;
        require(isCurStudent(stuId), "No transcripts or current student, invalid operation");

        studsTrans[stuId].certificate = _trans.certificate;
        studsTrans[stuId].signature = _trans.signature;
        for(uint i = 0; i < _trans.courseList.length; ++i)
        {
            studsTrans[stuId].courseList.push( _trans.courseList[i]);
        }
    }

    function checkGraduateRequirement(uint256 _studId) external onlyAdmin view returns (bool)
    {
        if (studsTrans[_studId].certificate.status != EStudyStatus.InProgress)
            return true;
        else
            return false;
    }

    function findStudentIndex(uint256 _studId) private view returns (uint)
    {
        for (uint i = 0; i < curStudArray.length; ++i)
        {
            if (curStudArray[i] == _studId)
                return i;
        }
        return type(uint).max; //return a invalid value if not found;
    }

    function removeStudent(uint256 _studId) external onlyAdmin
    {
        uint studIndex = findStudentIndex(_studId);
        require(studIndex != type(uint).max, "student not in list");

        //because solidity only support pop in array. move last available address instead;
        curStudArray[studIndex] = curStudArray[curStudArray.length - 1];
        curStudArray.pop();
    }
}

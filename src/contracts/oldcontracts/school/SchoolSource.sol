//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "../commoncontracts/IOffice.sol";
import "./ISchoolSource.sol";

contract SchoolSource is ISchoolSource
{
    struct Signatures
    {
        uint256 certSig;
        uint256 transSig;
    }

    mapping(uint256 => Transcript_Info) private studsTrans;
    uint256[] private curStudArray;
    mapping(uint256 => Signatures) private graduatedStudentInfo; //studentId => signature
    IOffice officeContract;

    constructor(address officeContractAddress)
    {
        officeContract = IOffice(officeContractAddress);
    }
    modifier onlyAdmin(address _verify)
    {
        require(officeContract.isOwnerOrOfficer(_verify), "only school admin is allowed");
        _;
    }

    function addGraduatedStudent(address _verify, uint256 id, uint256 _certSig, uint256 _TranSig) external onlyAdmin(_verify)
    {
        Signatures memory sigs;
        sigs.certSig = _certSig;
        sigs.transSig = _TranSig;
        graduatedStudentInfo[id] = sigs;
    }

    function getGraduatedStudentCertificateSignature(uint256 id) external view returns (uint256) 
    {
        return graduatedStudentInfo[id].certSig;
    }

    function getGraduatedStudentTranscriptSignature(uint256 id) external view returns (uint256) 
    {
        return graduatedStudentInfo[id].transSig;
    }

    function newStudent(address _verify, Student_Info memory _stdInfo, School_Info memory _schoolInfo) external onlyAdmin(_verify)
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

    function addCurrentStudentCourseInfo(address _verify,uint256 _studId, Course_Info memory _courseList) external onlyAdmin(_verify)
    {
        studsTrans[_studId].courseList.push(_courseList);
    }

    function getCurrentStudentCertificate(address _verify,uint256 _stuId) external view onlyAdmin(_verify) returns (Certificate_Info memory)
    {
        return studsTrans[_stuId].certificate;
    }

    function getCurrentStudentTranscript(address _verify, uint256 _stuId) external view onlyAdmin(_verify) returns (Transcript_Info memory)
    {
        return studsTrans[_stuId];
    }
    
    function isCurrentStudent(address _verify,uint256 _studId) external view onlyAdmin(_verify) returns (bool)
    {
        return isCurStudent(_verify, _studId);
    }

    function isCurStudent(address _verify,uint256 _stuId) private view onlyAdmin(_verify) returns (bool)
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

    function updateStudentCertificate(address _verify, Certificate_Info memory _cert) onlyAdmin(_verify) external
    {
        uint256 stuId = _cert.studentDetails.id;
        require (isCurStudent(_verify, stuId), "No current student, should admission first");

        studsTrans[stuId].certificate = _cert;
    }

    function setStudentTranscript(address _verify, Transcript_Info memory _trans) onlyAdmin(_verify) external
    {
        uint256 stuId = _trans.certificate.studentDetails.id;
        require(isCurStudent(_verify, stuId), "No transcripts or current student, invalid operation");

        studsTrans[stuId].certificate = _trans.certificate;
        studsTrans[stuId].signature = _trans.signature;
        for(uint i = 0; i < _trans.courseList.length; ++i)
        {
            studsTrans[stuId].courseList.push( _trans.courseList[i]);
        }
    }

    function checkGraduateRequirement(address _verify, uint256 _studId) external onlyAdmin(_verify) view returns (bool)
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

    function removeStudent(address _verify, uint256 _studId) external onlyAdmin(_verify)
    {
        uint studIndex = findStudentIndex(_studId);
        require(studIndex != type(uint).max, "student not in list");

        //because solidity only support pop in array. move last available address instead;
        curStudArray[studIndex] = curStudArray[curStudArray.length - 1];
        curStudArray.pop();
    }
}

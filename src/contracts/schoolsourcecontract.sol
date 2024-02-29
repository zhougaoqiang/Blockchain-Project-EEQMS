//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";
import "./certificatescontract.sol";
import "./schoolofficeinterface.sol";

contract School_Source_Smart_Contract
{
    mapping(uint256 => Certificate_Info) private studsCert;
    mapping(uint256 => Transcript_Info) private studsTrans;
    uint256[] private curStudArray;
    mapping(uint256 => address) private graduatedStudentInfo; //studentId => studentContractAddress
    Interface_School_Office_Smart_Contract officeContract;

    //TODO: need add admin info;
    constructor(address officeContractAddress)
    {
        officeContract = Interface_School_Office_Smart_Contract(officeContractAddress);
    }

    function addGraduatedStudent(uint256 id, address _add) external
    {
        graduatedStudentInfo[id] = _add;
    }

    function getGraduatedStudent(uint256 id) external view returns (address)
    {
        return graduatedStudentInfo[id];
    }

    function newStudent(Student_Info memory _stdInfo, School_Info memory _schoolInfo) external
    {
        uint256 studentId = _stdInfo.id; //school must create a unqiure id for student first;
        Certificate_Info memory cert;
        cert.schoolInfo = _schoolInfo;
        cert.honor = EHonor.None;
        cert.status = EStudyStatus.InProgress;
        cert.admissionTimestamp = block.timestamp;
        cert.studentDetails = _stdInfo;
        studsCert[studentId] = cert;
        curStudArray.push(studentId);
        studsTrans[studentId].certificate = cert;
    }

    function addCurrentStudentCourseInfo(uint256 _studId, Course_Info memory _courseList) external
    {
        studsTrans[_studId].courseList.push(_courseList);
    }

    function getCurrentStudentCertificate(uint256 _stuId) external view returns (Certificate_Info memory)
    {
        return studsCert[_stuId];
    }

    function getCurrentStudentTranscript(uint256 _stuId) external view returns (Transcript_Info memory)
    {
        return studsTrans[_stuId];
    }
    
    function isCurrentStudent(uint256 _studId) external view returns (bool)
    {
        return isCurStudent(_studId);
    }

    function isCurStudent(uint256 _stuId) private view returns (bool)
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

    function updateStudentCertificate(Certificate_Info memory _cert) external
    {
        uint256 stuId = _cert.studentDetails.id;
        require (isCurStudent(stuId), "No current student, should admission first");

        studsCert[stuId] = _cert;
    }

    function setStudentTranscript(Transcript_Info memory _trans) external
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

    function checkGraduateRequirement(uint256 _studId) external view returns (bool)
    {
        if (studsCert[_studId].status != EStudyStatus.InProgress)
        {
            return true;
        }
        else
        {
            return false;
        }
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

    function removeStudent(uint256 _studId) external
    {
        uint studIndex = findStudentIndex(_studId);
        require(studIndex != type(uint).max, "student not in list");

        //because solidity only support pop in array. move last available address instead;
        curStudArray[studIndex] = curStudArray[curStudArray.length - 1];
        curStudArray.pop();
    }
}

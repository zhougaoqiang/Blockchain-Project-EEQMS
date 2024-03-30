//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "../commoncontracts/IOffice.sol";

interface ISchoolSource
{
    function addGraduatedStudent(address _verify, uint256 id, uint256 _certSig, uint256 _tranSig) external;
    function getGraduatedStudentCertificateSignature(uint256 id) external view returns (uint256);
    function getGraduatedStudentTranscriptSignature(uint256 id) external view returns (uint256);
    function newStudent(address _verify, Student_Info memory _stdInfo, School_Info memory _schoolInfo) external;
    function addCurrentStudentCourseInfo(address _verify, uint256 _studId, Course_Info memory _courseList) external;
    function getCurrentStudentCertificate(address _verify, uint256 _stuId) external view returns (Certificate_Info memory);
    function getCurrentStudentTranscript(address _verify, uint256 _stuId) external view returns (Transcript_Info memory);
    function isCurrentStudent(address _verify, uint256 _studId) external view returns (bool);
    function updateStudentCertificate(address _verify, Certificate_Info memory _cert)external;
    function setStudentTranscript(address _verify, Transcript_Info memory _trans) external;
    function checkGraduateRequirement(address _verify, uint256 _studId) external view returns (bool);
    function removeStudent(address _verify, uint256 _studId) external;
}

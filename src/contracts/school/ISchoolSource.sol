//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "../commoncontracts/IOffice.sol";

interface ISchoolSource
{
    function addGraduatedStudent(uint256 id, address _add) external;
    function getGraduatedStudent(uint256 id) external view returns (address);
    function newStudent(Student_Info memory _stdInfo, School_Info memory _schoolInfo) external;
    function addCurrentStudentCourseInfo(uint256 _studId, Course_Info memory _courseList) external;
    function getCurrentStudentCertificate(uint256 _stuId) external view returns (Certificate_Info memory);
    function getCurrentStudentTranscript(uint256 _stuId) external view returns (Transcript_Info memory);
    function isCurrentStudent(uint256 _studId) external view returns (bool);
    function updateStudentCertificate(Certificate_Info memory _cert)external;
    function setStudentTranscript(Transcript_Info memory _trans) external;
    function checkGraduateRequirement(uint256 _studId) external view returns (bool);
    function removeStudent(uint256 _studId) external;
}

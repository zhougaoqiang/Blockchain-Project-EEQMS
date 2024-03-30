//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";

interface ICertificate
{
    // function acceptedCertifcate(address _verify, address _office) external;
    // function transferOwnership(address _verify,address _stud) external; 
    function setStudentAddress(address _verify,address _add) external returns (bool);
    function setCertificate(address _verify,Certificate_Info memory _cert) external returns (bool);
    // function setSignature(address _verify,uint256 _sig) external;
    // function setCourseInfo(address _verify,Course_Info[] memory _courseList) external;
    function getCertificate(address _verify) external view returns (Certificate_Info memory);
    // function getTranscript(address _verify) external view returns (Transcript_Info memory);
}
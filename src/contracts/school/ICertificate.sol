//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";

interface ICertificate
{
    function transferOwnership(address _stud) external; 
    function setCertificate(Certificate_Info memory _cert) external;
    function setSignature(uint256 _sig) external;
    function setCourseInfo(Course_Info[] memory _courseList) external;
    function getCertificate() external view returns (Certificate_Info memory);
    function getTranscript() external view returns (Transcript_Info memory);
}
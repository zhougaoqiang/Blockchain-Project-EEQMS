//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";

interface IPerson
{
    function getPersonalInfo() external view returns (Personal_Info memory);
    function getAllCertificates() external view returns (Certificate_Info[] memory);
    function getCertificatesCounts() external view returns (uint);
    function getCertificateByIndex( uint _index) external view returns (Certificate_Info memory);
    // function getTranscript(address _verify, Certificate_Info memory _cert) external view returns (Transcript_Info memory);
}
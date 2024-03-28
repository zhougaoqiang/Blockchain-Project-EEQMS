//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/CommonDefinition.sol";
import "../commoncontracts/SchoolDefinition.sol";

interface IPerson
{
    function getPersonalInfo(address _verify) external view returns (Personal_Info memory);
    function getAllCertificates(address _verify) external view returns (Certificate_Info[] memory);
    function getCertificatesCounts(address _verify) external view returns (uint);
    function getCertificateByIndex(address _verify, uint _index) external view returns (Certificate_Info memory);
    function getTranscript(address _verify, Certificate_Info memory _cert) external view returns (Transcript_Info memory);
}
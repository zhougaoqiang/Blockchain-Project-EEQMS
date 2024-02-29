//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./otherdefinition.sol";
import "./schooldefinition.sol";
import "./certificatesinterface.sol";

interface Interface_Peronal_Smart_Contrac
{
    function transferOwnership(address newOwner) external; //gov call
    function getPersonalInfo() external view returns (Personal_Info memory);
    function getAllCertificates() external view  returns (Certificate_Info[] memory);
    function getTranscript(Certificate_Info memory _cert) external view returns (Transcript_Info memory);
}
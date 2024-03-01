//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

interface Interface_School_Verification_Service_Smart_Contract
{
    function getCertificateFee() external view returns (uint);
    function getTranscationFee() external view returns (uint);
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external payable returns (bool);
    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external payable returns (bool);
}
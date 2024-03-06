//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../commoncontracts/schooldefinition.sol";

interface Interface_Verification_Smart_Contract
{
    function getVerifyFee() external view returns (uint);
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external returns (bool);
    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external returns (bool);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";
import "./certificatesinterface.sol";
import "./schoolofficeinterface.sol";
import "./schoolsourceinterface.sol";

interface Interface_School_Verification_Service_Smart_Contract
{
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external view returns (bool);
    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external view returns (bool);
}
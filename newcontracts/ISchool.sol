//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";

interface ISchool
{
    // function getVerifyFee(address _verify) external view returns (uint);
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external returns (bool);
    // function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external returns (bool);
}

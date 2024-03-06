//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/schooldefinition.sol";
import "./certificatecontract.sol";
import "../commoncontracts/iofficecontract.sol";
import "./schoolsourcecontract.sol";
import "./iverificationcontract.sol";
import "../library/schoolhashlib.sol";

interface Interface_School_Smart_Contract
{
    function getVerifyFee() external view returns (uint);
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external payable returns (bool);
    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external payable returns (bool);
}

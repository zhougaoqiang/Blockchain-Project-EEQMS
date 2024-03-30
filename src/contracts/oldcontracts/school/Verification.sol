//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "./ICertificate.sol";
import "../library/schoolhashlib.sol";
import "./ISchoolSource.sol";
import "./IVerification.sol";

contract Verification is IVerification
{
    using Hash_Lib for *; //use hash library
    ISchoolSource sourceContract;

    constructor(address _source)
    {
        sourceContract = ISchoolSource(_source);
    }
 
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external view returns (bool) 
    {
        uint256 studId = _cert.studentDetails.id;
        uint256 sig = sourceContract.getGraduatedStudentCertificateSignature(studId);
        return Hash_Lib.verifyCertificate(_cert, sig);
    }

    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external view returns (bool)
    {
        uint256 studId = _trans.certificate.studentDetails.id;
        uint256 sig = sourceContract.getGraduatedStudentTranscriptSignature(studId);
        return Hash_Lib.verifyTranscript(_trans, sig);
    }
}
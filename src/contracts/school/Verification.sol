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
        ICertificate certInterface = ICertificate(sourceContract.getGraduatedStudent(studId));
        Certificate_Info memory certInDatabase = certInterface.getCertificate();
        return Hash_Lib.verifyCertificate(_cert, certInDatabase.signature);
    }

    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external view returns (bool)
    {
        ICertificate certInterface = ICertificate(sourceContract.getGraduatedStudent(_trans.certificate.studentDetails.id));
        uint256 signInDatabase = certInterface.getTranscript().signature;
        return Hash_Lib.verifyTranscript(_trans, signInDatabase);
    }
}
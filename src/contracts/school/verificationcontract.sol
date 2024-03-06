//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/schooldefinition.sol";
import "../commoncontracts/iofficecontract.sol";
import "./icertificatecontract.sol";
import "../library/schoolhashlib.sol";
import "./ischoolsourcecontract.sol";

contract Verification_Smart_Contract
{
    using Hash_Lib for *; //use hash library
    Interface_School_Source_Smart_Contract sourceContract;

    constructor(address _source)
    {
        sourceContract = Interface_School_Source_Smart_Contract(_source);
    }
 
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external view returns (bool) 
    {
        uint256 studId = _cert.studentDetails.id;
        Interface_Certificate_Smart_Contract certInterface = Interface_Certificate_Smart_Contract(
                                sourceContract.getGraduatedStudent(studId));
        Certificate_Info memory certInDatabase = certInterface.getCertificate();
        return Hash_Lib.verifyCertificate(_cert, certInDatabase.signature);
    }

    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external view returns (bool)
    {
        Interface_Certificate_Smart_Contract certInterface = Interface_Certificate_Smart_Contract(
                                sourceContract.getGraduatedStudent(_trans.certificate.studentDetails.id));
        uint256 signInDatabase = certInterface.getTranscript().signature;
        return Hash_Lib.verifyTranscript(_trans, signInDatabase);
    }
}
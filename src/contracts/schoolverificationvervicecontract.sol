//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";
import "./certificatesinterface.sol";
import "./schoolofficeinterface.sol";
import "./schoolsourceinterface.sol";

contract School_Verification_Service_Smart_Contract
{
    Interface_School_Office_Smart_Contract officeContract;
    Interface_School_Source_Smart_Contract sourceContract;

    constructor(address _office, address _source)
    {
        officeContract = Interface_School_Office_Smart_Contract(_office);
        sourceContract = Interface_School_Source_Smart_Contract(_source);
    }

    modifier onlyOwner()
    {
        require(officeContract.isAdmin(), "only owner allowed to do verification");
        _;
    }

    function verifyGraduatedStudentCert(Certificate_Info memory _cert) private view returns (bool)
    {
        uint256 studId = _cert.studentDetails.id;
        Interface_Certificate_Smart_Contract certInterface = Interface_Certificate_Smart_Contract(
                                sourceContract.getGraduatedStudent(studId));
        Certificate_Info memory certInDatabase = certInterface.getCertificate();

        if (certInDatabase.signature == _cert.signature)
            return true;
        else
            return false;
    }

    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external view onlyOwner returns (bool) 
    {
        return verifyGraduatedStudentCert(_cert);
    }

    function verifyGraduateStudentTrans(uint256 _studId, uint256 transSignature) private view returns (bool)
    {
        Interface_Certificate_Smart_Contract certInterface = Interface_Certificate_Smart_Contract(
                                sourceContract.getGraduatedStudent(_studId));
        uint256 signInDatabase = certInterface.getTranscript().signature;
        if (signInDatabase == transSignature)
            return true;
        else
            return false;
    }

    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external view onlyOwner returns (bool)
    {
        if (verifyGraduatedStudentCert(_trans.certificate))
        {
            return verifyGraduateStudentTrans(_trans.certificate.studentDetails.id, _trans.signature);
        }
        else
        {
            return false;
        }
    }
}
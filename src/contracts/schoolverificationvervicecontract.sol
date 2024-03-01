//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/schooldefinition.sol";
import "./interfaces/certificatesinterface.sol";
import "./interfaces/schoolofficeinterface.sol";
import "./interfaces/schoolsourceinterface.sol";
import "./library/schoolhashlib.sol";

contract School_Verification_Service_Smart_Contract
{
    using Hash_Lib for *; //use hash library

    Interface_School_Office_Smart_Contract officeContract;
    Interface_School_Source_Smart_Contract sourceContract;
    uint private verifyCertfee;
    uint private verifyTransfee;

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

    function withdrawToOffice() public onlyOwner
    {
        payable(address(officeContract)).transfer(address(this).balance);
    }

    function updateVerifyCertificateFee(uint _fee) public onlyOwner
    {
        verifyCertfee = _fee;
    }

    function updateVerifyTranscriptFee(uint _fee) public onlyOwner
    {
        verifyTransfee = _fee;
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
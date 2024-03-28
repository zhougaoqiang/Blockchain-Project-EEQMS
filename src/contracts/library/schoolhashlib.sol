//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";

library Hash_Lib
{
    function hashCertificate(Certificate_Info memory _cert) internal pure returns (uint256)
    {
        School_Info memory sch = _cert.schoolInfo;
        bytes32 schHash = keccak256(abi.encodePacked(
            sch.schoolContractAddress, sch.id, sch.add, sch.email,sch.name));
        Student_Info memory stud = _cert.studentDetails;
        bytes32 studHash = keccak256(abi.encodePacked(
            stud.studentAdd, stud.id, stud.nationality, stud.nric, stud.passport, stud.name, stud.add));
        bytes32 certHash = keccak256(abi.encodePacked(
            schHash, studHash, _cert.category, _cert.honor, _cert.status, _cert.major, _cert.description, 
            _cert.certificateId, _cert.admissionTimestamp, _cert.graduationTimestamp));
        return uint256(certHash);
    }

    function verifyCertificate(Certificate_Info memory _cert, uint256 siganature) internal pure returns (bool)
    {
        uint256 sig = hashCertificate(_cert);
        return siganature == sig;
    }

    function hashTranscript(Transcript_Info memory _trans, bool internalUse) internal pure returns (uint256)
    {
        uint256 certHash = 0;
        if (internalUse)
            certHash = _trans.certificate.signature;
        else
            certHash = hashCertificate(_trans.certificate);
        uint courseCount = _trans.courseList.length;
        bytes32 courseHash = bytes32(0);
        for(uint i = 0; i < courseCount; ++i)
        {
            courseHash = keccak256(abi.encodePacked(_trans.courseList[i].id, _trans.courseList[i].name, 
                _trans.courseList[i].professor, _trans.courseList[i].result, _trans.courseList[i].grade, courseHash));
        }
        bytes32 transHash = keccak256(abi.encodePacked(certHash, courseHash));
        return uint256(transHash);
    }

    function verifyTranscript(Transcript_Info memory _trans, uint256 siganature) internal pure returns (bool)
    {
        uint256 sig = hashTranscript(_trans, false);
        return siganature == sig;
    }
}
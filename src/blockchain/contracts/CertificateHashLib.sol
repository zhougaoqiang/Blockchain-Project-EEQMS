//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";

library CertificateHashLib
{
    function hashCertificate(Certificate_Info memory _cert) internal pure returns (uint256)
    {
        School_Info memory sch = _cert.schoolInfo;
        bytes32 schHash = keccak256(abi.encodePacked(sch.schoolContractAddress, sch.id, sch.add, sch.email,sch.name));
        Student_Info memory stud = _cert.studentDetails;
        bytes32 studHash = keccak256(abi.encodePacked(stud.id, stud.nationality, stud.nric, stud.passport, stud.name, stud.add));
        bytes32 certHash = keccak256(abi.encodePacked(schHash, studHash, _cert.category, _cert.honor, _cert.status, _cert.major, _cert.description, 
            _cert.certificateId, _cert.admissionTimestamp));
        return uint256(certHash);
    }
}
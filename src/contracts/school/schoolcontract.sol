//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/schooldefinition.sol";
import "./icertificatecontract.sol";
import "../commoncontracts/iofficecontract.sol";
import "./ischoolsourcecontract.sol";
import "./iverificationcontract.sol";
import "../library/schoolhashlib.sol";

contract School_Smart_Contract
{
    using Hash_Lib for * ;
    Interface_Office_Smart_Contract private officeContract;
    Interface_School_Source_Smart_Contract private sourceContract;
    Interface_Verification_Smart_Contract private verifyContract;
    uint private verifyFee;
    School_Info public schoolInfo;

    constructor(address _off, address _source, address _verify)
    {
        officeContract = Interface_Office_Smart_Contract(_off);
        sourceContract = Interface_School_Source_Smart_Contract(_source);
        verifyContract = Interface_Verification_Smart_Contract(_verify);
    }

    modifier onlyAdmin()
    {
        require(officeContract.isOwnerOrOfficer(msg.sender));
        _;
    }

    modifier onlyOwner()
    {
        require(officeContract.isOwner(), "only owner is allowed");
        _;
    }

    function getSchoolInfo() public view onlyOwner returns (School_Info memory)
    {
        return schoolInfo;
    }

    function updateSchoolInfo(School_Info memory _schoolInfo) public onlyOwner
    {
        schoolInfo = _schoolInfo; 
        //cannot update school contract address;
        schoolInfo.schoolContractAddress = address(this);
    }

    function withdraw() public onlyOwner
    {
        payable(address(officeContract)).transfer(address(this).balance);
    }

    function updateVerifyFee(uint _fee) public onlyAdmin
    {
        verifyFee = _fee;
    }
    
    function getVerifyFee() external view returns (uint)
    {
        return verifyFee;
    }

    function studentAdmission(Student_Info memory _stdInfo) public onlyAdmin
    {
        sourceContract.newStudent(_stdInfo, schoolInfo);
    }

    //core function: issue student certificate contract
    function studentGradutaion(uint256 _studId, address _stud, address newStudentContract) public onlyAdmin returns (address)
    {
        require (sourceContract.isCurrentStudent(_studId) && sourceContract.checkGraduateRequirement(_studId), "No current student, or not match graduate requirement");
        
        Certificate_Info memory cert =  sourceContract.getCurrentStudentCertificate(_studId);
        cert.signature = Hash_Lib.hashCertificate(cert);
        uint256 transSig = Hash_Lib.hashTranscript(sourceContract.getCurrentStudentTranscript(_studId), true);

        Interface_Certificate_Smart_Contract studContract = Interface_Certificate_Smart_Contract(newStudentContract);
        studContract.setCertificate(cert);
        studContract.setSignature(transSig);
        studContract.setCourseInfo(sourceContract.getCurrentStudentTranscript(_studId).courseList);
        studContract.transferOwnership(_stud);
        
        sourceContract.addGraduatedStudent(_studId, address(newStudentContract));
        sourceContract.removeStudent(_studId);
        return address(newStudentContract);
    }

    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external payable returns (bool)
    {
        require(msg.value >= verifyFee, "Insufficient fee for verification");
        return verifyContract.verifyGraduatedStudentCertificate(_cert);
    }

    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external payable returns (bool)
    {
        require(msg.value >= verifyFee, "Insufficient fee for verification");
        return verifyContract.verifyGraduateStudentTranscript(_trans);
    }
}

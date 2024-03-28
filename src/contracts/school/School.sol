//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "./ICertificate.sol";
import "../commoncontracts/IOffice.sol";
import "./ISchoolSource.sol";
import "./IVerification.sol";
import "../library/schoolhashlib.sol";
import "../TOKEN/IERC20.sol";
import "./ISchool.sol";

/*
the school smart contract should create after software release

company contract deploy sequence.
1. deploy office contract
2. deploy school source contract (need office contract address)
3. deploy verificationcontract (need school source contact)
4. deploy school smart contract with office, source, and verification contract, and ERC20 also.

ADDITIONAL:
the website should add register page and login page.
register function should follow above deploy sequence.

login page need user provide company smart contract address. we can return error if cannot get anything.

*/

contract School is ISchool
{
    using Hash_Lib for * ;
    IOffice private officeContract;
    ISchoolSource private sourceContract;
    IVerification private verifyContract;
    uint private verifyFee;
    School_Info public schoolInfo;
    IERC20 private tokenContract;

    constructor(address _off, address _source, address _verify, address _tokenContract)
    {
        officeContract = IOffice(_off);
        sourceContract = ISchoolSource(_source);
        verifyContract = IVerification(_verify);
        tokenContract = IERC20(_tokenContract);
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

        ICertificate studContract = ICertificate(newStudentContract);
        studContract.setCertificate(cert);
        studContract.setSignature(transSig);
        studContract.setCourseInfo(sourceContract.getCurrentStudentTranscript(_studId).courseList);
        studContract.transferOwnership(_stud);
        
        sourceContract.addGraduatedStudent(_studId, address(newStudentContract));
        sourceContract.removeStudent(_studId);
        return address(newStudentContract);
    }

    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external returns (bool)
    {
        require(tokenContract.transferFrom(msg.sender, address(this), 1*10**18), "Failed to transfer token for verification fee");
        // require(tokenContract.approve(address(msg.sender), 1*10**18), "Token transfer for verification fee failed");
        return verifyContract.verifyGraduatedStudentCertificate(_cert);
    }

    function verifyGraduateStudentTranscript(Transcript_Info memory  _trans) external returns (bool)
    {
        require(tokenContract.transferFrom(msg.sender, address(this), 2*10**18), "Failed to transfer token for verification fee");
        // require(tokenContract.approve(address(msg.sender), 2*10**18), "Token transfer for verification fee failed");
        return verifyContract.verifyGraduateStudentTranscript(_trans);
    }
}

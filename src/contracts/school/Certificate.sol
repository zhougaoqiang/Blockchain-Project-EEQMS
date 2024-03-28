//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "./ICertificate.sol";
import "../commoncontracts/IOffice.sol";

contract Certificate is ICertificate
{
    address private owner;
    Transcript_Info private trans;
    bool isAcceptedByStudent;
    IOffice officeContract;
    

    constructor()
    {
        owner = msg.sender;
        isAcceptedByStudent = false;
    }
    
    modifier onlyValidator(address _verify)
    {
        if (!isAcceptedByStudent)
        {
            require(_verify == owner, "Only owner can do this");
        }
        else 
        {
            require(_verify == owner || officeContract.isOfficer(_verify), "Only owner can do this");
        }
        _;
    }

    function transferOwnership(address _verify, address _stud) external onlyValidator(_verify)
    {
        owner = _stud;
    }

    function acceptedCertifcate(address _verify, address _office) external onlyValidator(_verify)
    {
        isAcceptedByStudent = true;
        officeContract = IOffice(_office);
    }
    
    function setCertificate(address _verify, Certificate_Info memory _cert) external onlyValidator(_verify)
    {
        trans.certificate  = _cert;
    }

    function setCourseInfo(address _verify, Course_Info[] memory _courseList) external onlyValidator(_verify)
    {
        for (uint i = 0; i < _courseList.length; ++i)
        {
            trans.courseList.push(_courseList[i]);
        }
    }

    function setSignature(address _verify, uint256 _sig) external onlyValidator(_verify)
    {
        trans.signature = _sig;
    }

    function getCertificate(address _verify) external onlyValidator(_verify) view returns (Certificate_Info memory)
    {
        return trans.certificate;
    }

    function getTranscript(address _verify) external onlyValidator(_verify) view returns (Transcript_Info memory)
    {
        return trans;
    }
}
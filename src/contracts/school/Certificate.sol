//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../commoncontracts/SchoolDefinition.sol";
import "./ICertificate.sol";

contract Certificate is ICertificate
{
    address private owner;
    Transcript_Info private trans;

    constructor()
    {
        owner = msg.sender;
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    function transferOwnership(address _stud) external onlyOwner 
    {
        owner = _stud;
    }

    function setCertificate(Certificate_Info memory _cert) external onlyOwner
    {
        trans.certificate  = _cert;
    }

    function setCourseInfo(Course_Info[] memory _courseList) external onlyOwner
    {
        for (uint i = 0; i < _courseList.length; ++i)
        {
            trans.courseList.push(_courseList[i]);
        }
    }

    function setSignature(uint256 _sig) external onlyOwner
    {
        trans.signature = _sig;
    }

    function getCertificate() external onlyOwner view returns (Certificate_Info memory)
    {
        return trans.certificate;
    }

    function getTranscript() external onlyOwner view returns (Transcript_Info memory)
    {
        return trans;
    }
}
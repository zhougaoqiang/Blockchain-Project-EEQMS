//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

contract Certificate_Smart_Contract
{
    address public owner;
    address private student;
    Transcript_Info private trans;

    constructor(address _studAdd, Certificate_Info memory _cert, uint256 _signature, Course_Info[] memory _courseList)
    {
        owner = msg.sender;
        student = _studAdd;
        // trans = _trans; // not support
        trans.certificate  = _cert;
        trans.signature = _signature;

        for (uint i = 0; i < _courseList.length; ++i)
        {
            trans.courseList.push(_courseList[i]);
        }
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    modifier onlyOwnerAndStudent()
    {
        require(msg.sender == owner || msg.sender == student, "Only owner and student allowed");
        _;
    }

    function getCertificate() external onlyOwnerAndStudent view returns (Certificate_Info memory)
    {
        return trans.certificate;
    }

    function getTranscript() external onlyOwnerAndStudent view returns (Transcript_Info memory)
    {
        return trans;
    }
}
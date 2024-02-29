//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

contract Certificate_Smart_Contract
{
    address public owner;
    School_Info private school;
    Certificate_Info private cert;
    Transcript_Info private trans;

    constructor(Certificate_Info memory _cert, uint256 _signature, Course_Info[] memory _courseList)
    {
        owner = msg.sender;
        school = _cert.schoolInfo;
        cert = _cert;
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

    function transferOwnership(address _newOwner) public onlyOwner
    {
        owner = _newOwner;
    }

    function getCertificate() public onlyOwner view returns (Certificate_Info memory)
    {
        return cert;
    }

    function getTranscript() public onlyOwner view returns (Transcript_Info memory)
    {
        return trans;
    }
}
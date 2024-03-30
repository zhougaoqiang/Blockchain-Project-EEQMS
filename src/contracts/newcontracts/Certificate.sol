//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";
import "./ICertificate.sol";

contract Certificate is ICertificate
{
    address private school;
    address private student;
    Certificate_Info private cert;

    constructor()
    {
        school = msg.sender;
        // student = _stud;
    }

    function setStudentAddress(address _verify, address _add) external override returns (bool)
    {
        if (school == _verify)
        {
            student = _add;
            return true;
        }
        return false;
    }
    
    function setCertificate(address _verify, Certificate_Info memory _cert) external override returns (bool)
    {
        if (_verify == school)
        {
            cert = _cert;
            return true;
        }
        else
        {
            return false;
        }
        
    }

    function getCertificate(address _verify) external override view returns (Certificate_Info memory)
    {
        if (student == _verify || school == _verify)
        {
            return cert;
        }
        Certificate_Info memory _cert;
        return _cert;
    }

}
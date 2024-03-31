//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";
import "./ICertificate.sol";
import "./IPerson.sol";

contract Person is IPerson
{
    Personal_Info private personalInfo;
    Certificate_Info[] certificates;
    address owner;
    bool isPublic;

    constructor()
    {
        owner = msg.sender;
        isPublic = false;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, "only owner can do");
        _;
    }

    function setToPublic(bool _isPublic) public onlyOwner()
    {
        isPublic = _isPublic;
    }

    // before add certificate to self. please call acceptCertificateContract first. 
    function addCertificateContract(address _add) public onlyOwner()
    {
        ICertificate certContract = ICertificate(_add);
        Certificate_Info memory cert = certContract.getCertificate(msg.sender);
        certificates.push(cert);
    }

    function setPersonalInfo(Personal_Info memory _info) public onlyOwner()
    {
        personalInfo = _info;
    }

    function getPersonalInfo() external override view returns (Personal_Info memory) 
    {
        if (isPublic || msg.sender == owner)
        {
            return personalInfo;
        }
        else
        {
            Personal_Info memory _person;
            return _person;
        }
    }

    function getAllCertificates() external override view returns (Certificate_Info[] memory)
    {
        if (isPublic || msg.sender == owner)
        {
            return certificates;
        }
        else
        {
            Certificate_Info[] memory _certs;
            return _certs;
        }
    }

    function getCertificatesCounts() external override view returns (uint)
    {
        if (isPublic || msg.sender == owner)
        {
            return certificates.length;
        }
        else
        {
            return type(uint).max;
        }
    }

    function getCertificateByIndex(uint _index) external override view returns (Certificate_Info memory)
    {
        require(_index < certificates.length, "This certificate is not exist");
        
        if (isPublic || msg.sender == owner)
        {
            return certificates[_index];
        }
        else
        {
            Certificate_Info memory _cert;
            return _cert;
        }
    }
}
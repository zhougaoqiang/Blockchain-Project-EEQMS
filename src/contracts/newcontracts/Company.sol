//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";
import "./IGovernment.sol";
import "./ISchool.sol";
import "./IPerson.sol";

contract Company
{
    address owner;
    mapping(address => bool) private adminList;

    Personal_Info[] private candicatorsInfoList;
    mapping(uint256 => address) private candicatorAddresses;
    Company_Info public companyInfo;
    address governmentAddress;

    constructor(address _gov, string memory _uenNo, 
        string memory _name, string memory _profile, string memory _add)
    {
        governmentAddress = _gov;
        owner = msg.sender;
        companyInfo.uenNo = _uenNo;
        companyInfo.name = _name;
        companyInfo.profile = _profile;
        companyInfo.add = _add;
        companyInfo.id = uint256(keccak256(abi.encodePacked(_uenNo, _name, _profile, _add)));
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, "only owner allowed");
        _;
    }

    modifier onlyAdmin()
    {
        require(owner == msg.sender || adminList[msg.sender] == true, "only goverment admin is allowed");
        _;
    }

    function addAdmin(address _add) public onlyOwner()
    {
        adminList[_add] = true;
    }

    function removeAdmin(address _add) public onlyOwner()
    {
        adminList[_add] = false;
    }

    function setCompanyInfo(Company_Info memory _info) public onlyAdmin()
    {
        companyInfo = _info;
    }

    function addCandicator(Personal_Info memory _personalInfo, address _candicator) public onlyAdmin()
    {
        candicatorsInfoList.push(_personalInfo);
        candicatorAddresses[_personalInfo.id] = _candicator;
    }

    function removeCandicator(uint256 _id) public onlyAdmin() returns (bool)
    {
        for(uint i = 0; i < candicatorsInfoList.length; i++)
        {
            if (candicatorsInfoList[i].id == _id)
            {
                delete candicatorAddresses[_id];
                candicatorsInfoList[i] = candicatorsInfoList[candicatorsInfoList.length - 1];
                candicatorsInfoList.pop();
                return true;
            }
        }
        return false;
    }

    function getAllCandicators() public view onlyAdmin() returns (Personal_Info[] memory)
    {
        return candicatorsInfoList;
    }

    // id in personal infor;
    function getCandicatorCertifcates(uint256 _id) public view returns (Certificate_Info[] memory)
    {
        IPerson per = IPerson(candicatorAddresses[_id]);
        return per.getAllCertificates();
    }

    // core function verify candicator certificate.
    function verifyCandicatorCertificate(Certificate_Info memory _cert) public returns (bool)
    {
        IGovernment gov = IGovernment(governmentAddress);
        if (!gov.isRegisterSchool(_cert.schoolInfo.schoolContractAddress))
        {
            return false;
        }
        
        ISchool schoolContract = ISchool(_cert.schoolInfo.schoolContractAddress);
        return schoolContract.verifyGraduatedStudentCertificate(_cert);
    }

    // core function verify candicator certificates.
    function verifyStaffAllCertificate(uint256 _id) public returns (bool)
    {
        IPerson per = IPerson(candicatorAddresses[_id]);
        Certificate_Info[] memory _certs = per.getAllCertificates();
        for(uint i = 0; i < _certs.length; i++)
        {
            if (!verifyCandicatorCertificate(_certs[i]))
            {
                return false;
            }
        }

        return true;
    }
}
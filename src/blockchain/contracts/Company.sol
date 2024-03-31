//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";
import "./IGovernment.sol";
import "./ISchool.sol";
import "./IPerson.sol";
import "./CertificateHashLib.sol";
import "./openzeppelin/token/ERC20/IERC20.sol";

contract Company
{
    using CertificateHashLib for * ;
    event VerificationResult(bool result);
    event hasCertificate(uint256);
    address owner;
    mapping(address => bool) private adminList;

    Personal_Info[] private candidateInfoList;
    mapping(uint256 => address) private candidateAddresses;
    Company_Info public companyInfo;
    IGovernment governmentAddress;
    Certificate_Info public tmpCertifcate;
    IERC20 erc20;

    constructor(address _gov, string memory _uenNo, 
        string memory _name, string memory _profile, string memory _add, address _etk)
    {
        governmentAddress = IGovernment(_gov);
        owner = msg.sender;
        companyInfo.uenNo = _uenNo;
        companyInfo.name = _name;
        companyInfo.profile = _profile;
        companyInfo.add = _add;
        companyInfo.id = uint256(keccak256(abi.encodePacked(_uenNo, _name, _profile, _add)));
        erc20 = IERC20(_etk);
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
        candidateInfoList.push(_personalInfo);
        candidateAddresses[_personalInfo.id] = _candicator;
    }

    function removeCandicator(uint256 _id) public onlyAdmin() returns (bool)
    {
        for(uint i = 0; i < candidateInfoList.length; i++)
        {
            if (candidateInfoList[i].id == _id)
            {
                delete candidateAddresses[_id];
                candidateInfoList[i] = candidateInfoList[candidateInfoList.length - 1];
                candidateInfoList.pop();
                return true;
            }
        }
        return false;
    }

    function getAllCandidates() public view onlyAdmin() returns (Personal_Info[] memory)
    {
        return candidateInfoList;
    }

    // id in personal infor;
    function getSandidateCertifcates(uint256 _id) public view returns (Certificate_Info[] memory)
    {
        IPerson per = IPerson(candidateAddresses[_id]);
        return per.getAllCertificates();
    }

 //step 1
    function fetchCertificate(uint256 _id, uint8 _index) public returns (bool)
    {
        IPerson per = IPerson(candidateAddresses[_id]);
        if (_index < per.getAllCertificates().length)
        {
            Certificate_Info[] memory _certs = per.getAllCertificates();
            tmpCertifcate = _certs[_index];
            return true;
        }
        return false;
    }

    //step 2
    function verifyCertificateIssuedSchool() public view returns (bool)
    {
        return governmentAddress.isRegisterSchool(tmpCertifcate.schoolInfo.schoolContractAddress);
    }

    // step 3 opt 1
    function verifyStaffCertificate() public returns (bool)
    {
        ISchool schoolContract = ISchool(tmpCertifcate.schoolInfo.schoolContractAddress);
        bool result = schoolContract.verifyGraduatedStudentCertificate(tmpCertifcate);
        emit VerificationResult(result);
        return result;
    }

    //step 3 opt 2.  ///better, should use this
    function verifyStaffCertificateSignature() public view returns (bool)
    {
        uint256 hc = CertificateHashLib.hashCertificate(tmpCertifcate);
        ISchool schoolContract = ISchool(tmpCertifcate.schoolInfo.schoolContractAddress);
        bool result = schoolContract.directVerifyGraduatedStudentCertificate(msg.sender, tmpCertifcate.studentDetails.id, hc);
        return result;
    }

    //any admin or owner can check balance, however, only the owner can receive register company rewards.
    function getBanlance() public view returns (uint256)
    {
        return erc20.balanceOf(msg.sender);
    }
}
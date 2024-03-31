//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";
import "./ICertificate.sol";
import "./ISchool.sol";
import "./CertificateHashLib.sol";
import "./openzeppelin/token/ERC20/IERC20.sol";

contract School is ISchool
{
    event hasCertificateResult(uint256);
    event graduationResult(bool);
    using CertificateHashLib for * ;

    struct StudIdNamePair
    {
        uint256 id;
        string name;
    }

    // using Hash_Lib for * ;
    School_Info public schoolInfo;
    address owner;
    mapping(address => bool) private adminList;
    mapping(uint256 => Certificate_Info) private studsCerts;
    StudIdNamePair[] studentArray;
    mapping(uint256 => uint256) private certSignatures; //signature generate after graduate
    IERC20 erc20;
    constructor(string memory _schoolId, string memory _name, string memory _phyAdd, string memory _email, address _erc20)
    {
        owner = msg.sender;
        schoolInfo.schoolContractAddress = address(this);
        schoolInfo.id = _schoolId;
        schoolInfo.name = _name;
        schoolInfo.add = _phyAdd;
        schoolInfo.email = _email;
        erc20 = IERC20(_erc20);
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

    function updateSchoolInfo(School_Info memory _schInfo) public onlyAdmin()
    {
        schoolInfo = _schInfo;
    }

    function studentAdmission(Student_Info memory _stdInfo, ECertificateCategory _category, string memory _major) public onlyAdmin()
    {
        uint256 studentId = _stdInfo.id; //school must create a unqiure id for student first;
        Certificate_Info memory cert;
        cert.schoolInfo = schoolInfo;
        cert.honor = EHonor.None;
        cert.status = EStudyStatus.InProgress;
        cert.admissionTimestamp = block.timestamp;
        cert.studentDetails = _stdInfo;
        cert.certificateId = studentId;
        cert.category = _category;
        cert.major = _major;
        studsCerts[studentId] = cert;

        StudIdNamePair memory pair;
        pair.id = studentId;
        pair.name = _stdInfo.name;
        studentArray.push(pair);
    }

    function getStudCert(uint256 _studId) public onlyAdmin() view returns (Certificate_Info memory)
    {
        return studsCerts[_studId];
    }

    function setStudCert(uint256 _stuId, EHonor _honor, EStudyStatus _status,
                        string memory _decription) public onlyAdmin()
    {
        studsCerts[_stuId].honor = _honor;
        studsCerts[_stuId].status = _status;
        studsCerts[_stuId].description = _decription;
    }

    function getAllStudent() public onlyAdmin() view returns (StudIdNamePair[] memory)
    {
        return studentArray;
    }

    //core function: issue student certificate contract
    //para 1: student id (create by school)
    //para 2: student account
    //para 3: certifcate address, should deployed by website or manually deployed
    function studentGradutaion(uint256 _studId, address _stud, address newStudentContract) public onlyAdmin() returns (bool)
    {
        for(uint i = 0; i < studentArray.length; i++)
        {
            if (studentArray[i].id == _studId) //must current student
            {
                if (studsCerts[_studId].status == EStudyStatus.InProgress) //must graduate
                {
                    emit graduationResult(false);
                    return false;
                }
                //get hash
                studsCerts[_studId].graduationTimestamp =block.timestamp;
                studsCerts[_studId].signature = CertificateHashLib.hashCertificate(studsCerts[_studId]);
                
                ICertificate studContract = ICertificate(newStudentContract);
                studContract.setCertificate(msg.sender, studsCerts[_studId]);
                if (!studContract.setStudentAddress(msg.sender, _stud))
                {
                    emit graduationResult(false);
                    return false;
                }
                    
                certSignatures[_studId] = studsCerts[_studId].signature;

                //remove in current student list;
                studentArray[i] = studentArray[studentArray.length - 1];
                studentArray.pop();
                emit graduationResult(true);
                return true;
            }
        }
        emit graduationResult(false);
        return false;
    }

    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external override returns (bool)
    {
        uint256 sig = CertificateHashLib.hashCertificate(_cert);
        emit hasCertificateResult(sig);
        return certSignatures[_cert.studentDetails.id] == sig;
    }

    // need support ERC20 here, this is better, no need check event
    // company must pay to school owner, not admin
    function directVerifyGraduatedStudentCertificate(address companyWallet, uint256 _studId, uint256 _signature) external view override returns (bool)
    {
        require(erc20.allowance(companyWallet, owner) > 1000, "not enought");
        return certSignatures[_studId] == _signature;
    }

     // only get the school owner's balance.
    function getBanlance() public view returns (uint256)
    {
        return erc20.balanceOf(owner);
    }
}

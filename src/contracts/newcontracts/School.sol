//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Definition.sol";
import "./ICertificate.sol";
import "./ISchool.sol";

contract School is ISchool
{
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

    constructor(string memory _schoolId, string memory _name, string memory _phyAdd, string memory _email)
    {
        owner = msg.sender;
        schoolInfo.schoolContractAddress = address(this);
        schoolInfo.id = _schoolId;
        schoolInfo.name = _name;
        schoolInfo.add = _phyAdd;
        schoolInfo.email = _email;
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

    function studentAdmission(Student_Info memory _stdInfo) public onlyAdmin()
    {
        uint256 studentId = _stdInfo.id; //school must create a unqiure id for student first;
        Certificate_Info memory cert;
        cert.schoolInfo = schoolInfo;
        cert.honor = EHonor.None;
        cert.status = EStudyStatus.InProgress;
        cert.admissionTimestamp = block.timestamp;
        cert.studentDetails = _stdInfo;
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

    function getAllStudent() public onlyAdmin() view returns (StudIdNamePair[] memory)
    {
        return studentArray;
    }

    function hashCertificate(Certificate_Info memory _cert) private pure returns (uint256)
    {
        School_Info memory sch = _cert.schoolInfo;
        bytes32 schHash = keccak256(abi.encodePacked(sch.schoolContractAddress, sch.id, sch.add, sch.email,sch.name));
        Student_Info memory stud = _cert.studentDetails;
        bytes32 studHash = keccak256(abi.encodePacked(stud.studentAdd, stud.id, stud.nationality, stud.nric, stud.passport, stud.name, stud.add));
        bytes32 certHash = keccak256(abi.encodePacked(schHash, studHash, _cert.category, _cert.honor, _cert.status, _cert.major, _cert.description, 
            _cert.certificateId, _cert.admissionTimestamp, _cert.graduationTimestamp));
        return uint256(certHash);
    }

    function verifyCertificate(Certificate_Info memory _cert, uint256 siganature) private pure returns (bool)
    {
        uint256 sig = hashCertificate(_cert);
        return siganature == sig;
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
                    return false;
                }
                //get hash
                studsCerts[_studId].signature = hashCertificate(studsCerts[_studId]);
                studsCerts[_studId].graduationTimestamp =block.timestamp;
                ICertificate studContract = ICertificate(newStudentContract);
                studContract.setCertificate(msg.sender, studsCerts[_studId]);
                if (!studContract.setStudentAddress(msg.sender, _stud))
                    return false;
                certSignatures[_studId] = studsCerts[_studId].signature;

                //remove in current student list;
                studentArray[i] = studentArray[studentArray.length - 1];
                studentArray.pop();
                return true;
            }
        }
        return false;
    }

    // need support ERC20 here
    function verifyGraduatedStudentCertificate(Certificate_Info memory _cert) external view override returns (bool)
    {
        // require(tokenContract.transferFrom(msg.sender, address(this), 1*10**18), "Failed to transfer token for verification fee");
        return verifyCertificate(_cert, certSignatures[_cert.studentDetails.id]);
    }
}

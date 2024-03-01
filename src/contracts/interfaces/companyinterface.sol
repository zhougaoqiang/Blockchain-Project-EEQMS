//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./otherdefinition.sol";

interface Interface_Company_Smart_Contract
{
    function transferOwnership(address newOwner) external;
    function getCompanyInfo() external view returns (Company_Info memory);
    function addCompanyAdmins(address _admin) external;
    function removeAllAdmins() external;
    function addStaff(Personal_Info memory _personalInfo, address staffContractAdd) external;
    function removeStaff(uint256 _id) external;
    function verifyStaffCertificate(uint256 _id, bool verifyTransAlso) external payable returns (bool);
}
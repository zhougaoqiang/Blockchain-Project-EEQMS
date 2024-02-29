//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

interface Interface_School_Office_Smart_Contract
{
    function isAdmin() external view returns (bool);
    function transferOwnership(address _newOwner) external;
    function addOfficer(address _newOfficer) external;
    function removeOfficer(address _officer) external;
    function getSchoolInfo() external view returns (School_Info memory);
    function updateSchoolInfo(School_Info memory _schoolInfo) external;                                                                    
}
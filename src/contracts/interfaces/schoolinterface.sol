//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

interface Interface_School_Smart_Contract
{
    function setSchoolSourceContract(address _add) external;
    function setSchoolVerificationServiceContract(address _add) external;
    function getSchoolOfficeContract() external view returns (address);
    function getSchoolSourceContract() external view returns (address);
    function getSchoolVerificationServiceContract() external view returns (address);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

interface Interface_School_Smart_Contract
{
    function getSchoolOfficeContract() external view returns (address);
    function getSchoolSourceContract() external view returns (address);
    function getSchoolVerificationServiceContract() external view returns (address);
}

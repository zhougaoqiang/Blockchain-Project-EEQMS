//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Interface_Government_Smart_Contract
{
    function isRegisterSchool(address _add) external view returns (bool);
    function isRegisterCompany(address _add) external view returns (bool);
}
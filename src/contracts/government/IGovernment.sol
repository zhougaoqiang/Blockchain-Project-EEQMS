//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGovernment//this contract address will publish to all
{
    function isRegisterSchool(address _add) external view returns (bool);
    function isRegisterCompany(address _add) external view returns (bool);
    function isRegisterPerson(address _add) external view returns (bool);
}
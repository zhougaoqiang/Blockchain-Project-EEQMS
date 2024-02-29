//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./schooldefinition.sol";

interface Interface_Certificate_Smart_Contract
{
    function getCertificate() external view returns (Certificate_Info memory);
    function getTranscript() external view returns (Transcript_Info memory);
}
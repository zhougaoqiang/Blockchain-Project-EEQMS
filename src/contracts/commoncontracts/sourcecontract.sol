//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./iofficecontract.sol";

contract Source_Smart_Contract
{
    Interface_Office_Smart_Contract officeContract;
    uint count;
    address[] private subSourceAdds;

    constructor(address _officeAdd)
    {
        count = 0;
        officeContract = Interface_Office_Smart_Contract(_officeAdd);
    }

    modifier onlyAdmin()
    {
        require(officeContract.isOwnerOrOfficer(msg.sender), "only admin allowed");
        _;
    }

    function findAddressIndexInArray(address _add) private view returns (uint)
    {
        for(uint i = 0; i < count; ++i)
        {
            if (_add == subSourceAdds[i])
                return i;
        }
        return type(uint).max;
    }

    function hasAddress(address _add) external onlyAdmin view returns (bool)
    {
        uint index = findAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function addAddress(address _add) external onlyAdmin
    {
        subSourceAdds.push(_add);
        count++;
    }

    function getAddress(uint index) external view onlyAdmin returns (address)
    {
        require(index < count, "not in list");
        return subSourceAdds[index];
    }

    function removeAddress(address _add) external onlyAdmin
    {
        uint index = findAddressIndexInArray(_add);
        require(index != type(uint).max, "not in list");

        subSourceAdds[index] = subSourceAdds[count -1];
        subSourceAdds.pop();
        count--;
    }

    function removeAddressByIndex(uint index) external onlyAdmin
    {
        require(index < count, "not in list");
        subSourceAdds[index] = subSourceAdds[count -1];
        subSourceAdds.pop();
        count--;
    }
}
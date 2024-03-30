//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IOffice.sol";
import "./ISource.sol";
import "hardhat/console.sol";
/*
the source contract always need office contract support.
*/


contract Source is ISource
{
    IOffice officeContract;
    uint count;
    address[] private subSourceAdds;

    constructor(address _officeAdd)
    {
        count = 0;
        officeContract = IOffice(_officeAdd);
    }

    modifier onlyAdmin(address _add)
    {
        require(officeContract.isOwnerOrOfficer(_add), "only admin allowed");
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

    function hasAddress(address _add) external view returns (bool)
    {
        console.log("check has address =>", _add);
        uint index = findAddressIndexInArray(_add);
        if (index != type(uint).max)
            return true;
        else
            return false;
    }

    function addAddress(address _verify, address _add) external onlyAdmin(_verify)
    {
        subSourceAdds.push(_add);
        count++;

        console.log("add address =>", _add);
        console.log("count => ", count);
    }

    function getAddress(address _verify, uint index) external view onlyAdmin(_verify) returns (address)
    {
        require(index < count, "not in list");
        return subSourceAdds[index];
    }

    function removeAddress(address _verify, address _add) external onlyAdmin(_verify)
    {
        uint index = findAddressIndexInArray(_add);
        require(index != type(uint).max, "not in list");

        subSourceAdds[index] = subSourceAdds[count -1];
        subSourceAdds.pop();
        count--;
    }

    function removeAddressByIndex(address _verify, uint index) external onlyAdmin(_verify)
    {
        require(index < count, "not in list");
        subSourceAdds[index] = subSourceAdds[count -1];
        subSourceAdds.pop();
        count--;
    }
}
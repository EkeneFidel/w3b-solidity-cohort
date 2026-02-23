// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyManagement {
    address public owner;
    IERC20 public paymentToken;
    uint256 public propertyFee;
    uint256 public propertyCount;

    struct Property {
        uint256 id;
        string name;
        string location;
        bool active;
    }

    mapping(uint256 => Property) public properties;

    constructor(address tokenAddress, uint256 fee) {
        owner = msg.sender;
        paymentToken = IERC20(tokenAddress);
        propertyFee = fee;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Not owner");
    }

    function createProperty(
        string memory name,
        string memory location
    ) public onlyOwner {
        if (propertyFee > 0) {
            bool success = paymentToken.transferFrom(
                msg.sender,
                address(this),
                propertyFee
            );
            require(success, "Payment failed");
        }

        propertyCount++;

        properties[propertyCount] = Property({
            id: propertyCount,
            name: name,
            location: location,
            active: true
        });
    }

    function removeProperty(uint256 id) public onlyOwner {
        require(properties[id].active, "Property does not exist");
        properties[id].active = false;
    }

    function getProperty(uint256 id) public view returns (Property memory) {
        return properties[id];
    }
}

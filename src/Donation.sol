// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/IERC20.sol";

contract Donation {
    event Donated(address indexed donor, uint256 amount);
    event Withdrawn(address indexed receiver, uint256 amount);
    event NextOwnerUpdated(address nextOwner);
    event OwnerChanged(address newOwner);

    address public owner;
    address nextOwner;
    mapping(address => mapping(address => uint256)) donations;

    constructor() {
        owner = msg.sender;
    }

    function donate(address _stableToken, uint256 _amount) external {
        require(msg.sender != address(0), "zero address detected");
        require(_amount > 0, "can't donate zero value");
        require(IERC20(_stableToken).balanceOf(msg.sender) >= _amount, "insufficient funds");

        IERC20(_stableToken).transferFrom(msg.sender, address(this), _amount);

        donations[msg.sender][_stableToken] = donations[msg.sender][_stableToken] + _amount;

        emit Donated(msg.sender, _amount);
    }

    function withdraw(address _stableToken) external {
        onlyOwner();

        uint256 contractBalance = IERC20(_stableToken).balanceOf(address(this));

        require(contractBalance > 0, "no funds in contract");

        IERC20(_stableToken).transfer(owner, contractBalance);

        emit Withdrawn(owner, contractBalance);
    }

    function setNextOwner(address _nextOwner) external {
        onlyOwner();

        nextOwner = _nextOwner;

        emit NextOwnerUpdated(_nextOwner);
    }

    function acceptOwnership() external {
        require(msg.sender == nextOwner, "only next owner can accept ownership");

        owner = nextOwner;

        nextOwner = address(0);

        emit OwnerChanged(owner);
    }

    function showContractBalance(address _stableToken) external view returns (uint256) {
        return IERC20(_stableToken).balanceOf(address(this));
    }

    function onlyOwner() private view {
        require(msg.sender == owner, "not owner");
    }
}
